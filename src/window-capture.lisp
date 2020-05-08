;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Capture the screen using Windows.

(in-package :org.shirakumo.fraf.trial.vr.windows)

(cffi:define-foreign-library direct-x-11 (t (:default "d3d11")))
(cffi:load-foreign-library 'direct-x-11)

(defun enumerate-outputs (adapter &optional (index 0))
  (cffi:with-foreign-objects ((foreign-pointer :pointer)
                              (foreign-pointer-2 :pointer))
    (com-on:check-hresult (dxgi-adapter-enum-outputs adapter index foreign-pointer))
    (cffi:mem-ref foreign-pointer :pointer))) ;works

(defun duplicate-output (output-1 device)
  (cffi:with-foreign-object (foreign-pointer :pointer)
    (com-on:check-hresult (dxgi-output-1-duplicate-output output-1 device foreign-pointer))
    (cffi:mem-ref foreign-pointer :pointer)))

(defun acquire-next-frame (output-duplication &key (timeout 0))
  "Returns the next frame as a d3d11 texture 2d. Returns NIL in case of timeout. Signals in case of other error."
  (cffi:with-foreign-objects ((info-pointer :pointer)
                              (resource-pointer :pointer))
    (let ((ret-val
            (dxgi-output-duplication-acquire-next-frame
             output-duplication timeout info-pointer resource-pointer)))
      (when (eq ret-val :error-wait-timeout)
        (return-from acquire-next-frame nil))
      (unless (eq ret-val :ok)
        (error "acquire-next-frame ~a" ret-val)))
    (cffi:with-foreign-objects ((foreign-guid 'com-on:guid)
                                (out-pointer :pointer))
      (setf (cffi:mem-ref foreign-guid 'com-on:guid) iid-id3d11texture2d)
      (com-on:check-hresult
       (dxgi-resource-query-interface (cffi:mem-ref resource-pointer :pointer) foreign-guid out-pointer))
      (values (cffi:mem-ref out-pointer :pointer)
              (cffi:mem-ref resource-pointer :pointer)
              (cffi:mem-ref info-pointer :pointer)))))

(defun release-frame (output-duplication)
  (com-on::check-return (output-duplication-release-frame output-duplication))) ; works

(defun texture-description (texture)
  (cffi:with-foreign-object (description-pointer '(:struct d3d-11-texture-2d-description))
    (d3d-11-texture-2d-description texture description-pointer)
    (cffi:mem-ref description-pointer '(:struct d3d-11-texture-2d-description)))) ; works



(defun register-texture-for-interop (interop-handle gl-texture-name texture)
  (let ((handle
          (register-object interop-handle texture gl-texture-name :texture-2d :read-write)))
    (if (cffi:null-pointer-p handle)
        (error "error in register-texture-for-interop: ~a"
               (ecase (last-error)
                 (3221684334 :error-open-failed)
                 (3221684230 :error-invalid-handle)
                 (3221684237 :error-invalid-data)))
        handle)))

(defun copy-resource (context source destination)
  (d3d-11-device-context-copy-resource context destination source))

(defun adapter-from-dxgi-device (dxgi-device)
  (cffi:with-foreign-object (foreign-pointer :pointer)
    (dxgi-device-adapter dxgi-device foreign-pointer)
    (cffi:mem-ref foreign-pointer :pointer)))

(defun d3d-11-create-device (dxgi-adapter &key (driver-type :hardware) (flags '(:bgra-support)) (sdk-version 7))
  (cffi:with-foreign-objects ((device-pointer-pointer :pointer)
                              (device-context-pointer-pointer :pointer))
    (com-on:check-hresult
     (%d3d11-create-device dxgi-adapter driver-type (cffi:null-pointer) flags (cffi:null-pointer) 0 sdk-version 
                                        ; this will return a 11.0 device on a 11.1 machine
                           device-pointer-pointer (cffi:null-pointer) device-context-pointer-pointer))
    (values 
     (cffi:mem-ref device-pointer-pointer :pointer)
     (cffi:mem-ref device-context-pointer-pointer :pointer))))

(defun output-1-from-output (output)
  (cffi:with-foreign-objects ((foreign-pointer :pointer)
                             ; (foreign-guid '(:struct com-on::guid))
                              (foreign-guid 'com-on:guid))
                                        ;(setf (cffi:mem-ref foreign-guid '(:struct com-on::guid)) iid-idxgioutput1)
    (setf (cffi:mem-ref foreign-guid 'com-on:guid) iid-idxgioutput1)
    (dxgi-output-query-interface output foreign-guid foreign-pointer)
    (cffi:mem-ref foreign-pointer :pointer)))

(defun dxgi-device-from-d3d-11-device (output)
  (cffi:with-foreign-objects ((foreign-pointer :pointer)
                              (foreign-guid 'com-on:guid))
    (setf (cffi:mem-ref foreign-guid 'com-on:guid) iid-idxgidevice)
    (d3d-11-device-query-interface output foreign-guid foreign-pointer)
    (cffi:mem-ref foreign-pointer :pointer)))

(defun create-desktop-capture () ;; from mmozeiko
  (multiple-value-bind (device d3d-11-context)
      (d3d-11-create-device (cffi:null-pointer) :driver-type :hardware)
    (let* ((dxgi-device (dxgi-device-from-d3d-11-device device))
           (adapter (adapter-from-dxgi-device dxgi-device))
           (output (enumerate-outputs adapter))
           (output-1 (output-1-from-output output))
           (dxgi-duplication (duplicate-output output-1 device))
           (d3d-11-texture (make-d3d-11-texture device))
           (dx-device (open-device device))
           (opengl-texture (car (gl:gen-textures 1)))
           (opengl-destination-texture (car (gl:gen-textures 1)))
           (dx-texture (register-texture-for-interop dx-device opengl-texture d3d-11-texture)))
      (lock-object dx-device dx-texture)
      (dxgi-output-1-release output-1)
      (dxgi-output-release output)
      (dxgi-adapter-release adapter)
      (dxgi-device-release dxgi-device)
      (d3d-11-device-release device)
      (gl:bind-texture :texture-2d opengl-destination-texture)
      (gl:tex-parameter :texture-2d :texture-base-level 0)
      (gl:tex-parameter :texture-2d :texture-max-level 0)
      (gl:tex-image-2d :texture-2d 0 :rgb 1920 1080 0 :bgr :unsigned-short (cffi:null-pointer))
      (values opengl-texture opengl-destination-texture d3d-11-texture dx-texture dx-device d3d-11-context dxgi-duplication))))

(defun capture-desktop-frame (dxgi-duplication context dx-device dx-texture d3d-11-texture)
  (multiple-value-bind (resource-texture resource)
      (acquire-next-frame dxgi-duplication)
    (when resource-texture
      (unlock-object dx-device dx-texture)
      (copy-resource context resource-texture d3d-11-texture)
      (lock-object dx-device dx-texture)
      (d3d-11-texture-2d-release resource-texture)
      (dxgi-resource-release resource)
      (dxgi-output-duplication-release-frame dxgi-duplication)
      (return-from capture-desktop-frame t))))

(defun make-d3d-11-texture (device)
  (cffi:with-foreign-objects ((foreign-desc '(:struct d3d-11-texture-2d-description)))
    (cffi:with-foreign-slots ((width height mip-levels array-size format sample usage bind-flags
                                     cpu-access-flags misc-flags)
                              foreign-desc (:struct d3d-11-texture-2d-description))
      (Cffi:with-foreign-object (foreign-sample '(:struct dxgi-sample))
        (cffi:with-foreign-slots ((count quality) foreign-sample (:struct dxgi-sample))
          (setf width 1920
                height 1080
                misc-flags 0
                cpu-access-flags 0
                bind-flags 0
                count 1
                quality 0
                mip-levels 1
                array-size 1
                format 87 ; DXGI_FORMAT_B8G8R8A8_UNORM
                sample foreign-sample
                usage 0 )))
      (cffi:with-foreign-object (foreign-pointer :pointer)
        (com-on:check-hresult 
                (d3d-11-device-create-texture-2d device foreign-desc (cffi:null-pointer)
                                                foreign-pointer))
        (cffi:mem-ref foreign-pointer :pointer)))))

(let ((opengl-texture)
      (opengl-destination-texture)
      (d3d-11-texture)
      (dx-texture)
      (dx-device)
      (d3d-11-context)
      (dxgi-duplication))
  (defun interop-setup ()
    (multiple-value-bind (opengl-texture* opengl-destination-texture* d3d-11-texture* dx-texture*
                          dx-device* d3d-11-context* dxgi-duplication*)
        (create-desktop-capture)
      (setf opengl-texture opengl-texture*
            opengl-destination-texture opengl-destination-texture*
            d3d-11-texture d3d-11-texture*
            dx-texture dx-texture*
            dx-device dx-device*
            d3d-11-context d3d-11-context*
            dxgi-duplication dxgi-duplication*)))
  (defun interop-pre-frame ()
    (capture-desktop-frame  dxgi-duplication d3d-11-context dx-device dx-texture d3d-11-texture)
    (copy-gl-textures opengl-texture opengl-destination-texture))
  (defun interop-post-frame ())
  (defun gl-texture-name ()
    opengl-destination-texture))

(defmethod trial:create-context :after ((context trial:context)) (interop-setup))

(defmethod trial:paint :around ((obj trial::textured-entity) target)
  (let ((tex (trial::texture obj)))
    (when tex
      (gl:active-texture :texture0)
      (gl:bind-texture (trial::target tex) (gl-texture-name))
      (call-next-method)
      (gl:bind-texture (trial::target tex) 0))))

;;; come up with a better way of doing this.

(let ((pointer))
  (defun copy-gl-textures (source destination)
    (unless pointer (setf pointer (%glfw::get-proc-address "glCopyImageSubData")))
    (cffi:foreign-funcall-pointer pointer nil
                                  :uint source ;srcName
                                  %gl::enum :texture-2d ;srcTarget
                                  :int 0 ;srcLevel
                                  :int 0 ;srcX
                                  :int 0 ;srcY
                                  :int 0 ;srcZ
                                  :uint destination ;destination
                                  %gl::enum :texture-2d ;destinationTarget
                                  :int 0 ;dstLevel
                                  :int 0 ;dstX
                                  :int 0 ;dstY
                                  :int 0 ;dstZ
                                  :uint 1920 ;srcWidth
                                  :uint 1080 ;srcHeight
                                  :uint 1 ;srcDepth
                                  :void))
  (defun copy-image-sub-data ()
    pointer))
