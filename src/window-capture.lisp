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
  (doors.ui::find-window :window-name "portacle")
  ;(cffi:with-foreign-string (name "Portacle") (find-window-a (cffi:null-pointer) name))
  )


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
  (cffi:foreign-funcall-pointer (aref (interop-foreign-function-table) 1) nil
                                :pointer dx-device :void))
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

;; from https://github.com/apitrace/dxsdk/blob/master/Include/d3dcommon.h
(cffi:defcenum d3d-driver-type
  (:unknown 0)
  (:hardware 1)
  (:reference 2)
  (:null 3)
  (:software 4)
  (:warp 5))

(cffi:defcenum feature-level
  (:9-1 #x9100)
  (:9-2 #x9200)
  (:9-3 #x9300)
  (:10-0 #xa000)
  (:10-1 #xa100)
  (:11-0 #xb000)
  (:11-1 #xb100)
  (:12-0 #xc000)
  (:12-1 #xc100))

(cffi:defbitfield create-bitfield-flag
  (:single-threaded #x1)
  (:debug #x2)
  (:switch-to-ref #x4)
  (:prevent-internal-threading-optimizations #x8)
  (:bgra-support #x20)
  (:debuggable #x40)
  (:prevent-altering-layer-settings-from-registry #x80)
  (:disable-gpu-timeout #x100)
  (:video-support #x800))

(cffi:defcenum d3d-result
  (:file-not-found #x887c0002)
  (:too-many-unique-state-objects #x887c0001)
  (:too-many-unique-view-objects #x887c0003)
  (:deferred-context-map-without-initial-discard #x887c0004)
  (:invalid-call #x887a0001)
  (:was-still-drawing #x887a000a)
  (:fail #x80004005)
  (:invalid-arg #x80070057)
  (:out-of-memory #x8007000e)
  (:notimpl #x80004001)
  (:unsupported #x887a0004)
  (:false #x1)
  (:ok 0))

(cffi:defcfun (%d3d11-create-device "D3D11CreateDevice") d3d-result
  (dxgi-adapter :pointer)
  (driver-type d3d-driver-type)
  (hmodule :pointer)
  (flags create-bitfield-flag)
  (feature-levels-pointer :pointer)
  (feature-levels-count :uint)
  (sdk-version :uint)
  (d3d11-device :pointer)
  (feature-level-pointer :pointer)
  (device-context-pointer :pointer))

(defun d3d11-create-device (dxgi-adapter &key (driver-type :hardware) (flags '(:bgra-support)) (sdk-version 7))
  (let* (;(device-pointer (cffi:foreign-alloc :pointer))
        ; (device-context-pointer (cffi:foreign-alloc :pointer))
         )
    (cffi:with-foreign-objects ((device-pointer-pointer :pointer)
                                (device-context-pointer-pointer :pointer))
     ; (print device-pointer)
      ;(print device-context-pointer)
      ;(setf (cffi:mem-ref device-pointer-pointer :pointer)  device-pointer)
      ;(setf (cffi:mem-ref device-context-pointer-pointer :pointer)  device-context-pointer)
      
     ; (print device-pointer-pointer)
     ; (print device-context-pointer-pointer)
      (values (%d3d11-create-device dxgi-adapter driver-type (cffi:null-pointer) flags (cffi:null-pointer) 0 ; this will return a 11.0 device on a 11.1 machine
                                    sdk-version device-pointer-pointer (cffi:null-pointer) device-context-pointer-pointer)
              (cffi:mem-ref device-pointer-pointer :pointer)
              (cffi:mem-ref device-context-pointer-pointer :pointer))))) ; appears to work, sometimes returns :OK

(defun duplicate-output (dxgi-output)
  "Returns a pointer to an IXGIOutputDuplicationInterface obtained by calling IDXGIOutput1::DuplicateOutput"
  nil)
