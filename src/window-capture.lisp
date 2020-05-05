;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Capture the screen using Windows.
(in-package #:org.shirakumo.fraf.trial.vr)
(cffi:define-foreign-library direct-x-10 (t (:default "d3dx10")))
(cffi:define-foreign-library direct-x-11 (t (:default "d3d11")))
;(cffi:define-foreign-library direct-x-12 (t (:default "d3d12")))

(cffi:load-foreign-library 'direct-x-10)
(cffi:load-foreign-library 'direct-x-11)
;(cffi:load-foreign-library 'direct-x-12) ;c++ only

(cffi:define-foreign-library ole32
  (T (:default "Ole32")))
(cffi:load-foreign-library 'ole32)

(cffi:define-foreign-library user32
  (T (:default "User32")))
(cffi:load-foreign-library 'user32)

(cffi:defctype dword :uint32)
(cffi:defctype word :uint16)
(cffi:defctype long :int32)
(cffi:defctype short :int16)
(cffi:defctype byte :uint8)
(cffi:defctype wchar :uint16)
(cffi:defctype uint-ptr #+64-bit :uint64 #-64-bit :uint32)

(cffi:defcenum coinit
  (:apartment-threaded #x2)
  (:multi-threaded #x0)
  (:disable-ole1dde #x4)
  (:speed-over-memory #x8))

(cffi:defcenum hresult
  (:ok #x00000000)
  (:false #x00000001)
  (:polled-device #x00000002)
  (:abort #x80004004)
  (:cancelled #x800704C7)
  (:access-denied #x80070005)
  (:fail #x80004005)
  (:handle #x80070006)
  (:invalid-arg #x80070057)
  (:no-interface #x80004002)
  (:not-implemented #x80004001)
  (:out-of-memory #x8007000e)
  (:pointer #x80004003)
  (:unexpected #x8000ffff)
  (:input-lost #x8007001e)
  (:not-acquired #x8007000c)
  (:not-initialized #x80070015)
  (:other-has-priority #x80070005)
  (:invalid-parameter #x80070057)
  (:not-buffered #x80040207)
  (:acquired #x800700aa)
  (:handle-exists #x80070005)
  (:unplugged #x80040209)
  (:device-full #x80040201)
  (:device-not-reg #x80040154)
  ;; KLUDGE: for Xinput in win32-error
  (:not-connected #x048F))

(cffi:defctype hwnd :void)
(cffi:defctype refiid :void)

(cffi:defcfun (create-for-window "CreateForWindow") hresult
  (window :pointer)
  (riid :pointer)
  (result :pointer))

(cffi:defcfun (get-active-window "GetActiveWindow") :pointer)
(cffi:defcfun (get-foreground-window "GetForegroundWindow") :pointer) ;work
(cffi:defcfun (get-desktop-window "GetDesktopWindow") :pointer)
(cffi:defcfun (get-parent "GetParent") :pointer (hwnd :pointer))
(cffi:defcfun (find-window-a "FindWindowA")
    :pointer (class-name :pointer :char)
  (window-name :pointer :char))

(defun portacle-hwnd ()
  "Returns the HWND of the currently running Portacle instance."
  (cffi:with-foreign-string (name "Portacle") (find-window-a (cffi:null-pointer) name)))


(cffi:define-foreign-library dwm (T (:default "dwmapi")))
(cffi:load-foreign-library 'dwm)

(cffi:define-foreign-library kernel32 (T (:default "Kernel32")))
(cffi:load-foreign-library 'kernel32)

(cffi:defcfun
    (d311-surface-from-dxgi "CreateDirect3D11SurfaceFromDXGISurface") hresult
  (dxgi-surface :pointer)
  (inspectable :pointer))

(cffi:defcfun
    (d311-device-from-dxgi "CreateDirect3D11DeviceFromDXGIDevice") hresult
  (dxgi-surface :pointer)
  (inspectable :pointer))

(defun screen-output ()
  (ldx.dxgi:enum-outputs (ldx.dxgi:enum-adapters (ldx.dxgi:create-dxgi-factory) 0)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; switch to using com-on

(in-package :org.shirakumo.fraf.trial.vr.windows)


(defun enumerate-adapters-1 (factory-1 &optional (index 0))
  (cffi:with-foreign-object (foreign-pointer :pointer)
    (com-on::check-return (factory-1-enum-adapters-1 factory-1 index foreign-pointer))
    (cffi:mem-ref foreign-pointer :pointer))) ;works

(defun enumerate-outputs (adapter &optional (index 0))
  (cffi:with-foreign-objects ((foreign-pointer :pointer)
                              (foreign-pointer-2 :pointer)
                              (foreign-guid '(:struct com-on::guid)))
    (com-on::check-return (dxgi-adapter-enum-outputs adapter index foreign-pointer))
    (cffi:mem-ref foreign-pointer :pointer))) ;works



 ; appears to work, sometimes returns :OK

(defun duplicate-output (output-1 device)
  (cffi:with-foreign-object (foreign-pointer :pointer)
    (com-on::check-return (dxgi-output-1-duplicate-output output-1 device foreign-pointer))
    (cffi:mem-ref foreign-pointer :pointer)))

(defun duplicated-output-from-defaults ()
  (duplicate-output (enumerate-outputs (enumerate-adapters-1 (create-dxgi-factory-1)))
                    (d3d11-create-device (cffi:null-pointer))))

(defun acquire-next-frame (output-duplication &key (timeout 0))
  "Returns the next frame as a d3d11 texture 2d. Returns NIL in case of timeout. Signals in case of other error."
  (cffi:with-foreign-objects ((info-pointer :pointer)
                              (resource-pointer :pointer))
    (let ((ret-val
            (dxgi-output-duplication-acquire-next-frame output-duplication timeout info-pointer resource-pointer)))
      (when (eq ret-val :error-wait-timeout)
        (return-from acquire-next-frame nil))
      (unless (eq ret-val :ok)
        (error "acquire-next-frame ~a" ret-val)))
    (cffi:with-foreign-objects ((foreign-guid '(:struct com-on::guid))
                                (out-pointer :pointer))
      (setf (cffi:mem-ref foreign-guid '(:struct com-on::guid)) iid-id3d11texture2d)
      (com-on::check-return
       (dxgi-resource-query-interface (cffi:mem-ref resource-pointer :pointer) foreign-guid out-pointer))
      (values (cffi:mem-ref out-pointer :pointer)
              (cffi:mem-ref resource-pointer :pointer)
              (cffi:mem-ref info-pointer :pointer))))) ; works



(defun release-frame (output-duplication)
  (com-on::check-return (output-duplication-release-frame output-duplication))) ; works

(defun texture-description (texture)
  (cffi:with-foreign-object (description-pointer '(:struct d3d-11-texture-2d-description))
    (d3d-11-texture-2d-description texture description-pointer)
    (cffi:mem-ref description-pointer '(:struct d3d-11-texture-2d-description)))) ; works

(defun interop-extension-present-p () (%glfw::extension-supported-p "WGL_NV_DX_interop2"))

(let ((cache nil))
  (defun interop-foreign-function-table ()
    "Returns a table of foreign function pointers for WGL_NV_DX_interop. Order of functions is same as in the
   section 'New Procedures and Functions' in the extensions registry entry for WGL_NV_DX_interop."
    (if cache
        cache
        (setf cache (vector (%glfw::get-proc-address "wglDXSetResourceShareHandleNV")
                            (%glfw::get-proc-address "wglDXOpenDeviceNV")
                            (%glfw::get-proc-address "wglDXCloseDeviceNV")
                            (%glfw::get-proc-address "wglDXRegisterObjectNV")
                            (%glfw::get-proc-address "wglDXUnregisterObjectNV")
                            (%glfw::get-proc-address "wglDXObjectAccessNV")
                            (%glfw::get-proc-address "wglDXLockObjectsNV")
                            (%glfw::get-proc-address "wglDXUnlockObjectsNV"))))))

;; WGL_NV_DX_interop
;; https://www.khronos.org/registry/OpenGL/extensions/NV/WGL_NV_DX_interop.txt
(cffi:defcenum access
  (:read-only 0)
  (:read-write 1)
  (:write-discard 2))

(defun set-resource-share-handle (dx-resource share-handle)
  (cffi:foreign-funcall-pointer (aref (interop-foreign-function-table) 0) nil
                                :pointer dx-resource :pointer share-handle :bool))
(defun open-device (dx-device)
  (let ((handle
          (cffi:foreign-funcall-pointer (aref (interop-foreign-function-table) 1) nil
                                        :pointer dx-device :pointer)))
    (if (cffi:null-pointer-p handle)
        (error "error: ~a" (last-error))
        handle)))

(defun close-device (handle)
  (cffi:foreign-funcall-pointer (aref (interop-foreign-function-table) 2) nil
                                :pointer handle :bool))
(defun register-object (device-handle dx-resource name type access)
  (cffi:foreign-funcall-pointer (aref (interop-foreign-function-table) 3) nil
                                :pointer device-handle :pointer dx-resource
                                :uint name %gl::enum type access access :pointer))
(defun unregister-object (device-handle device-object)
  (cffi:foreign-funcall-pointer (aref (interop-foreign-function-table) 4) nil
                                :pointer device-handle :pointer device-object :bool))
(defun object-access (object-handle access)
  (cffi:foreign-funcall-pointer (aref (interop-foreign-function-table) 5) nil
                                :pointer object-handle access access :bool))
(defun lock-object (device-handle object-handle)
  (cffi:with-foreign-object (object-handle-pointer :pointer)
    (setf (cffi:mem-ref object-handle-pointer :pointer) object-handle)
    (cffi:foreign-funcall-pointer (aref (interop-foreign-function-table) 6) nil
                                  :pointer device-handle :int 1 :pointer object-handle-pointer :bool)))
(defun unlock-object (device-handle object-handle)
  (cffi:with-foreign-object (object-handle-pointer :pointer)
    (setf (cffi:mem-ref object-handle-pointer :pointer) object-handle)
    (cffi:foreign-funcall-pointer (aref (interop-foreign-function-table) 7) nil
                                  :pointer device-handle :int 1 :pointer object-handle-pointer :bool)))

;;  (open-device d3d-11-device) to open a device for interop and get interop handle

(cffi:defcfun (last-error "GetLastError") :uint)

(defun register-texture-for-interop (interop-handle gl-texture-name texture)
  (let ((handle
          (register-object interop-handle texture gl-texture-name :texture-2d :read-write)))
    (if (cffi:null-pointer-p handle)
        (error "error in register-texture-for-interop: ~a"
               (ecase (last-error)
                 (3221684334 :error-open-failed)
                 (3221684230 :error-invalid-handle)
                 (3221684237 :error-invalid-data))) ;?
        handle)))


(defvar *d3d11-device* nil)
(defvar *d3d11-device-context* nil)
(defvar *d3d11-output-duplication* nil)
(defvar *d3d11-texture* nil)
(defvar *interop-device* nil)
(defvar *interop-texture* nil)
(defvar *gl-texture-int* nil)

(defun %interop-setup ()
  (let ((adapter (enumerate-adapters-1 (create-dxgi-factory-1))))
    (multiple-value-bind (device device-context) (d3d11-create-device adapter :driver-type :unknown)
      (setf *d3d11-device* device
            *d3d11-device-context* device-context))
    (setf *d3d11-output-duplication*
          (duplicate-output (enumerate-outputs adapter) *d3d11-device*))
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
          (format t "desc is ~a" (cffi:mem-ref foreign-desc '(:struct d3d-11-texture-2d-description)))
          (format t "error code ~a "
           (d3d11-device-create-texture-2d *d3d11-device* foreign-desc (cffi:null-pointer)
                                           foreign-pointer))
          (format t  "created texture ~a" (cffi:mem-ref foreign-pointer :pointer))
          (setf *d3d11-texture* (cffi:mem-ref foreign-pointer :pointer)))))
    (setf *interop-device* (open-device *d3d11-device*))
    (setf *gl-texture-int* (car (gl:gen-textures 1)))
    (setf *interop-texture* (register-texture-for-interop *interop-device*
                                                          *gl-texture-int* *d3d11-texture*)
    ) ; currently fails with ERROR_OPEN_FAILED
  ))
(defun copy-resource (context source destination)
  (d3d-11-device-context-copy-resource context destination source)) ; needs devicecontext



(defun interop-post-frame ()
  )

(defun interop-release ()
  )

(defmethod trial:create-context :after ((context trial:context)) (interop-setup))
(defmethod trial:destroy-context :before ((context trial:context)) (interop-release))

(defun test-texture-description ()
  (loop for i from 0 below 1000 do
        (progn (sleep 0.001)
               (print (when *d3d11-texture* (texture-description *d3d11-texture*))))))

;(print (texture-description (acquire-next-frame *d3d11-output-duplication*)))

(defun do-overlay ()
  (let ((overlay (3b-openvr::create-overlay "ab35cd" "def")))
    (prog1 overlay
      (3b-openvr::set-overlay-texture overlay *gl-texture-int*)
      (3b-openvr::show-overlay overlay))))
;(do-overlay)

(defun adapter-from-dxgi-device (dxgi-device)
  (cffi:with-foreign-object (foreign-pointer :pointer)
    (dxgi-device-adapter dxgi-device foreign-pointer)
    (cffi:mem-ref foreign-pointer :pointer)))
(defun d3d-11-create-device (dxgi-adapter &key (driver-type :hardware) (flags '(:bgra-support)) (sdk-version 7))
  (cffi:with-foreign-objects ((device-pointer-pointer :pointer)
                              (device-context-pointer-pointer :pointer))
    (com-on::check-return
     (%d3d11-create-device dxgi-adapter driver-type (cffi:null-pointer) flags (cffi:null-pointer) 0 sdk-version 
                                        ; this will return a 11.0 device on a 11.1 machine
                           device-pointer-pointer (cffi:null-pointer) device-context-pointer-pointer))
    (values 
     (cffi:mem-ref device-pointer-pointer :pointer)
     (cffi:mem-ref device-context-pointer-pointer :pointer))))

(defun output-1-from-output (output)
  (cffi:with-foreign-objects ((foreign-pointer :pointer)
                              (foreign-guid '(:struct com-on::guid)))
    (setf (cffi:mem-ref foreign-guid '(:struct com-on::guid)) iid-idxgioutput1)
    (dxgi-output-query-interface output foreign-guid foreign-pointer)
    (cffi:mem-ref foreign-pointer :pointer)))

(defun dxgi-device-from-d3d-11-device (output)
  (cffi:with-foreign-objects ((foreign-pointer :pointer)
                              (foreign-guid '(:struct com-on::guid)))
    (setf (cffi:mem-ref foreign-guid '(:struct com-on::guid)) iid-idxgidevice)
    (format t "query-interface ~a" (d3d-11-device-query-interface output foreign-guid foreign-pointer))
    (cffi:mem-ref foreign-pointer :pointer)))

(defun create-desktop-capture ()
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
           (dx-texture (register-texture-for-interop dx-device opengl-texture d3d-11-texture)))
      (lock-object dx-device dx-texture)
      (dxgi-output-1-release output-1)
      (dxgi-output-release output)
      (dxgi-adapter-release adapter)
      (dxgi-device-release dxgi-device)
      (d3d-11-device-release device)
      (values opengl-texture d3d-11-texture dx-texture dx-device d3d-11-context dxgi-duplication)))) ;; from mmozeiko

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
        (com-on::check-return 
                (d3d-11-device-create-texture-2d device foreign-desc (cffi:null-pointer)
                                                foreign-pointer))
        (cffi:mem-ref foreign-pointer :pointer)))))

(let ((opengl-texture)
      (d3d-11-texture)
      (dx-texture)
      (dx-device)
      (d3d-11-context)
      (dxgi-duplication))
  (defun interop-setup ()
    (multiple-value-bind (opengl-texture* d3d-11-texture* dx-texture*
                          dx-device* d3d-11-context* dxgi-duplication*)
        (create-desktop-capture)
      (setf opengl-texture opengl-texture*
            d3d-11-texture d3d-11-texture*
            dx-texture dx-texture*
            dx-device dx-device*
            d3d-11-context d3d-11-context*
            dxgi-duplication dxgi-duplication*)))
  (defun interop-pre-frame ()
    (capture-desktop-frame  dxgi-duplication d3d-11-context dx-device dx-texture d3d-11-texture))
  (defun interop-post-frame ())
  (defun gl-texture-name ()
    opengl-texture))

(in-package :org.shirakumo.fraf.trial)

(defmethod paint :around ((obj textured-entity) target)
  (let ((tex (texture obj)))
    (when tex
      (gl:active-texture :texture0)
                                        ;(format t "binding-texture ~a ~a ~a" (target tex) (gl-name tex) target)
      (gl:bind-texture (target tex) 1;(gl-name tex)
                       )
      (call-next-method)
      (gl:bind-texture (target tex) 0))))

;;; come up with a better way of doing this.
