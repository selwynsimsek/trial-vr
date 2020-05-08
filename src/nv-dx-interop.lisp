;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; WGL_NV_DX_interop2 API. Used to expose the DirectX resource obtained from the Desktop
;;; Duplication API as an OpenGL texture.

;; https://www.khronos.org/registry/OpenGL/extensions/NV/WGL_NV_DX_interop.txt
;; https://www.khronos.org/registry/OpenGL/extensions/NV/WGL_NV_DX_interop2.txt

(in-package :org.shirakumo.fraf.trial.vr.windows)

(defun interop-extension-present-p () (%glfw::extension-supported-p "WGL_NV_DX_interop2"))

(cffi:defcenum access
  (:read-only 0)
  (:read-write 1)
  (:write-discard 2))

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


