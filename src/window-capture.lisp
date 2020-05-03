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


;; from https://github.com/apitrace/dxsdk/blob/master/Include/d3dcommon.h




(defun duplicate-output (dxgi-output)
  "Returns a pointer to an IXGIOutputDuplicationInterface obtained by calling IDXGIOutput1::DuplicateOutput"
  nil)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; switch to using com-on
(defpackage :org.shirakumo.fraf.trial.vr.windows
  (:use #:cl)
  (:local-nicknames (#:com-on #:org.shirakumo.com-on)
                    (#:trial-vr #:org.shirakumo.fraf.trial.vr)))
(in-package :org.shirakumo.fraf.trial.vr.windows)

(com-on::define-guid IID-IDXGIOutputDuplication #x191cfac3 #xa341 #x470d #xb2 #x6e #xa8 #x64 #xf4 #x28 #x31 #x9c)
(com-on::define-guid IID-IDXGIOutput1 #x00cddea8 #x939b #x4b83 #xa3 #x40 #xa6 #x85 #x22 #x66 #x66 #xcc)
(com-on::define-guid IID-IDXGIFactory1 #x770aae78 #xf26f #x4dba #xa8 #x29 #x25 #x3c #x83 #xd1 #xb3 #x87)
(com-on::define-guid IID-IDXGIAdapter1 #x29038f61 #x3839 #x4626 #x91 #xfd #x08 #x68 #x79 #x01 #x1a #x05)
(com-on::define-guid IID-IDXGIResource #x035f3ab4 #x482e #x4e50 #xb4 #x1f #x8a #x7f #x8b #xd8 #x96 #x0b)
(com-on::define-guid IID-ID3D11Texture2D #x6f15aaf2 #xd208 #x4e89 #x9a #xb4 #x48 #x95 #x35 #xd3 #x4f #x9c)

(com-on::define-comstruct output
  (set-private-data com-on::hresult (name :pointer) (data-size :uint) (data :pointer))
  (set-private-data-interface com-on::hresult (name :pointer) (unknown :pointer))
  (private-data com-on::hresult (name :pointer) (data-size :pointer) (data :pointer))
  (parent com-on::hresult (riid :pointer) (parent :pointer))
  (description com-on::hresult (desc :pointer))
  (display-mode-list com-on::hresult (enum-format :uint) (flags :uint) (num-modes :pointer) (desc :pointer))
  (find-closest-matching-mode com-on::hresult (mode-to-match :pointer) (closest-match :pointer) (concerned-device :pointer))
  (wait-for-vblank com-on::hresult)
  (take-ownership com-on::hresult (device :pointer) (exclusive :bool))
  (release-ownership :void)
  (gamma-control-capabilities com-on::hresult (gamma-capabilities :pointer))
  (set-gamma-control com-on::hresult (array :pointer))
  (gamma-control com-on::hresult (array :pointer))
  (set-display-surface com-on::hresult (scanout-surface :pointer))
  (display-surface-data com-on::hresult (destination :pointer))
  (frame-statistics com-on::hresult (statistics :pointer)))

(com-on::define-comstruct output-1
  (set-private-data com-on::hresult (name :pointer) (data-size :uint) (data :pointer))
  (set-private-data-interface com-on::hresult (name :pointer) (unknown :pointer))
  (private-data com-on::hresult (name :pointer) (data-size :pointer) (data :pointer))
  (parent com-on::hresult (riid :pointer) (parent :pointer))
  (description com-on::hresult (desc :pointer))
  (display-mode-list com-on::hresult (enum-format :uint) (flags :uint) (num-modes :pointer) (desc :pointer))
  (find-closest-matching-mode com-on::hresult (mode-to-match :pointer) (closest-match :pointer) (concerned-device :pointer))
  (wait-for-vblank com-on::hresult)
  (take-ownership com-on::hresult (device :pointer) (exclusive :bool))
  (release-ownership :void)
  (gamma-control-capabilities com-on::hresult (gamma-capabilities :pointer))
  (set-gamma-control com-on::hresult (array :pointer))
  (gamma-control com-on::hresult (array :pointer))
  (set-display-surface com-on::hresult (scanout-surface :pointer))
  (display-surface-data com-on::hresult (destination :pointer))
  (frame-statistics com-on::hresult (statistics :pointer))
  (display-mode-list-1 com-on::hresult (enum-format :uint) (flags :uint) (num-modes :pointer) (desc :pointer))
  (find-closest-matching-model-1 com-on::hresult (mode-to-match :pointer) (closest-match :pointer) (concerned-device :pointer))
  (display-surface-data-1 com-on::hresult (destination :pointer)) 
  (duplicate-output com-on::hresult (device :pointer) (output-duplication :pointer)))

(com-on::define-comstruct output-duplication
  (set-private-data com-on::hresult (name :pointer) (data-size :uint) (data :pointer))
  (set-private-data-interface com-on::hresult (name :pointer) (unknown :pointer))
  (private-data com-on::hresult (name :pointer) (data-size :pointer) (data :pointer))
  (parent com-on::hresult (riid :pointer) (parent :pointer))
  (description :void (desc :pointer))
  (acquire-next-frame com-on::hresult (timeout-in-milliseconds :uint) (frame-info :pointer) (desktop-resource :pointer))
  (frame-dirty-rects com-on::hresult (dirty-rects-buffer-size :uint) (dirty-rects-buffer :pointer) (dirty-rects-buffer-size-required :pointer))
  (frame-move-rects com-on::hresult (move-rects-buffer-size :uint) (move-rect-buffer :pointer) (move-rects-buffer-size-required :pointer))
  (frame-pointer-shape com-on::hresult (pointer-shape-buffer-size :uint) (shape-buffer :pointer) (shape-buffer-size-required :pointer) (pointer-shape-info :pointer))
  (map-desktop-surface com-on::hresult (locked-rect :pointer))
  (unmap-desktop-surface com-on::hresult)
  (release-frame com-on::hresult))

(cffi:defcfun (%create-dxgi-factory-1 "CreateDXGIFactory1") com-on::hresult (riid :pointer) (factory :pointer))

(defun create-dxgi-factory-1 ()
  (cffi:with-foreign-objects ((foreign-guid '(:struct com-on::guid))
                              (foreign-pointer :pointer))
    (setf (cffi:mem-ref foreign-guid '(:struct com-on::guid)) iid-idxgifactory1)
    (com-on::check-return (%create-dxgi-factory-1 foreign-guid foreign-pointer))
    (cffi:mem-ref foreign-pointer :pointer))) ; works

(com-on::define-comstruct factory-1
  (set-private-data com-on::hresult (name :pointer) (data-size :uint) (data :pointer))
  (set-private-data-interface com-on::hresult (name :pointer) (unknown :pointer))
  (private-data com-on::hresult (name :pointer) (data-size :pointer) (data :pointer))
  (parent com-on::hresult (riid :pointer) (parent :pointer))
  (enum-adapters com-on::hresult (adapter-index :uint) (adapter :pointer))
  (make-window-association com-on::hresult (hwnd :pointer) (flags :uint))
  (window-association com-on::hresult (window :pointer))
  (create-swap-chain com-on::hresult (device :pointer) (desc :pointer) (swap-chain :pointer))
  (create-software-adapter com-on::hresult (module :pointer) (adapter :pointer))
  (enum-adapters-1 com-on::hresult (adapter-index :uint) (adapter :pointer))
  (current-p :bool))

(com-on::define-comstruct adapter-1
  (set-private-data com-on::hresult (name :pointer) (data-size :uint) (data :pointer))
  (set-private-data-interface com-on::hresult (name :pointer) (unknown :pointer))
  (private-data com-on::hresult (name :pointer) (data-size :pointer) (data :pointer))
  (parent com-on::hresult (riid :pointer) (parent :pointer))
  (enum-outputs com-on::hresult (output-index :uint) (output :pointer))
  (description com-on::hresult (description :pointer))
  (check-interface-support com-on::hresult (interface-name :pointer) (umd-version :pointer))
  (description-1 com-on::hresult (description :pointer)))

(defun enumerate-adapters-1 (factory-1 &optional (index 0))
  (cffi:with-foreign-object (foreign-pointer :pointer)
    (com-on::check-return (factory-1-enum-adapters-1 factory-1 index foreign-pointer))
    (cffi:mem-ref foreign-pointer :pointer))) ;works

(defun enumerate-outputs (adapter-1 &optional (index 0))
  (cffi:with-foreign-objects ((foreign-pointer :pointer)
                              (foreign-pointer-2 :pointer)
                              (foreign-guid '(:struct com-on::guid)))
    (com-on::check-return (adapter-1-enum-outputs adapter-1 index foreign-pointer))
    (setf (cffi:mem-ref foreign-guid '(:struct com-on::guid)) IID-IDXGIOutput1)
    (com-on::check-return (output-query-interface 
                (cffi:mem-ref foreign-pointer :pointer) foreign-guid foreign-pointer-2))
    (cffi:mem-ref foreign-pointer-2 :pointer))) ;works

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
(cffi:defcenum d3d-driver-type
  (:unknown 0)
  (:hardware 1)
  (:reference 2)
  (:null 3)
  (:software 4)
  (:warp 5))
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
      (com-on::check-return  (%d3d11-create-device dxgi-adapter driver-type (cffi:null-pointer) flags (cffi:null-pointer) 0 ; this will return a 11.0 device on a 11.1 machine
                                                   sdk-version device-pointer-pointer (cffi:null-pointer) device-context-pointer-pointer))
      (values 
       (cffi:mem-ref device-pointer-pointer :pointer)
       (cffi:mem-ref device-context-pointer-pointer :pointer))))) ; appears to work, sometimes returns :OK

(defun duplicate-output (output-1 device)
  (cffi:with-foreign-object (foreign-pointer :pointer)
    (com-on::check-return (output-1-duplicate-output output-1 device foreign-pointer))
    (cffi:mem-ref foreign-pointer :pointer)))

(defun duplicated-output-from-defaults ()
  (duplicate-output (enumerate-outputs (enumerate-adapters-1 (create-dxgi-factory-1))) (d3d11-create-device (cffi:null-pointer))))

(defun acquire-next-frame (output-duplication &key (timeout 0))
  "Returns the next frame as a d3d11 texture 2d."
  (cffi:with-foreign-objects ((info-pointer :pointer)
                              (resource-pointer :pointer)
                              (cast-pointer :pointer))
    (com-on::check-return (output-duplication-acquire-next-frame output-duplication timeout info-pointer resource-pointer))
    (cffi:with-foreign-objects ((foreign-guid '(:struct com-on::guid))
                                (out-pointer :pointer))
      (setf (cffi:mem-ref foreign-guid '(:struct com-on::guid)) iid-id3d11texture2d)
      (com-on::check-return (resource-query-interface (cffi:mem-ref resource-pointer :pointer) foreign-guid out-pointer))
      (values (cffi:mem-ref out-pointer :pointer) (cffi:mem-ref info-pointer :pointer))))) ; works

(com-on::define-comstruct resource
  (set-private-data com-on::hresult (name :pointer) (data-size :uint) (data :pointer))
  (set-private-data-interface com-on::hresult (name :pointer) (unknown :pointer))
  (private-data com-on::hresult (name :pointer) (data-size :pointer) (data :pointer))
  (parent com-on::hresult (riid :pointer) (parent :pointer))
  (device com-on::hresult (rrid :pointer) (device :pointer))
  (shared-handle com-on::hresult (shared-handle :pointer))
  (usage com-on::hresult (usage :pointer))
  (set-eviction-priority com-on::hresult (eviction-priority :uint))
  (eviction-priority com-on::hresult (eviction-priority :pointer)))

(defun release-frame (output-duplication)
  (com-on::check-return (output-duplication-release-frame output-duplication))) ; works

(com-on::define-comstruct d3d-11-texture-2d
  (device :void (device :pointer))
  (private-data com-on::hresult (name :pointer) (data-size :pointer) (data :pointer))
  (set-private-data com-on::hresult (name :pointer) (data-size :uint) (data :pointer))
  (set-private-data-interface com-on::hresult (name :pointer) (unknown :pointer))
  (type :void (resource-dimension :pointer))
  (set-eviction-priority com-on::hresult (eviction-priority :uint))
  (eviction-priority com-on::hresult (eviction-priority :pointer))
  (description :void (description :pointer)))

(cffi:defcstruct dxgi-sample
  (count :uint)
  (quality :uint))

(cffi:defcstruct d3d-11-texture-2d-description
  (width :uint)
  (height :uint)
  (mip-levels :uint)
  (array-size :uint)
  (format :uint)
  (sample (:struct dxgi-sample))
  (usage :uint)
  (bind-flags :uint)
  (cpu-access-flags :uint)
  (misc-flags :uint))

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

;;  (open-device d3d-11-device) to open a device for interop and get interop handle

(defun register-texture-for-interop (interop-handle gl-texture-name texture)
  (register-object interop-handle texture gl-texture-name :texture-2d :read-only))
