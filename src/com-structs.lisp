(in-package #:org.shirakumo.fraf.trial.vr.windows)

(com-on::define-guid IID-IDXGIOutputDuplication #x191cfac3 #xa341 #x470d #xb2 #x6e #xa8 #x64 #xf4 #x28 #x31 #x9c)
(com-on::define-guid IID-IDXGIOutput1 #x00cddea8 #x939b #x4b83 #xa3 #x40 #xa6 #x85 #x22 #x66 #x66 #xcc)
(com-on::define-guid IID-IDXGIFactory1 #x770aae78 #xf26f #x4dba #xa8 #x29 #x25 #x3c #x83 #xd1 #xb3 #x87)
(com-on::define-guid IID-IDXGIAdapter1 #x29038f61 #x3839 #x4626 #x91 #xfd #x08 #x68 #x79 #x01 #x1a #x05)
(com-on::define-guid IID-IDXGIResource #x035f3ab4 #x482e #x4e50 #xb4 #x1f #x8a #x7f #x8b #xd8 #x96 #x0b)
(com-on::define-guid IID-ID3D11Texture2D #x6f15aaf2 #xd208 #x4e89 #x9a #xb4 #x48 #x95 #x35 #xd3 #x4f #x9c)
(com-on::define-guid IID-ID3D11DeviceContext #xc0bfa96c #xe089 #x44fb #x8e #xaf #x26 #xf8 #x79 #x61 #x90 #xda)
(com-on::define-guid IID-IDXGIDevice #x54ec77fa #x1377 #x44e6 #x8c #x32 #x88 #xfd #x5f #x44 #xc8 #x4c)

(com-on::define-comstruct dxgi-output
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

(com-on::define-comstruct dxgi-output-1
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

(cffi:defcenum dxgi-result
  (:ok 0)
  (:error-access-lost #x887a0026)
  (:error-wait-timeout #x887a0027)
  (:error-invalid-call #x887a0001))

(com-on::define-comstruct dxgi-output-duplication 
  (set-private-data com-on::hresult (name :pointer) (data-size :uint) (data :pointer))
  (set-private-data-interface com-on::hresult (name :pointer) (unknown :pointer))
  (private-data com-on::hresult (name :pointer) (data-size :pointer) (data :pointer))
  (parent com-on::hresult (riid :pointer) (parent :pointer))
  (description :void (desc :pointer))
  (acquire-next-frame dxgi-result (timeout-in-milliseconds :uint) (frame-info :pointer) (desktop-resource :pointer))
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

(com-on::define-comstruct dxgi-factory-1
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

(com-on::define-comstruct dxgi-adapter
  (set-private-data com-on::hresult (name :pointer) (data-size :uint) (data :pointer))
  (set-private-data-interface com-on::hresult (name :pointer) (unknown :pointer))
  (private-data com-on::hresult (name :pointer) (data-size :pointer) (data :pointer))
  (parent com-on::hresult (riid :pointer) (parent :pointer))
  (enum-outputs com-on::hresult (output-index :uint) (output :pointer))
  (description com-on::hresult (description :pointer))
  (check-interface-support com-on::hresult (interface-name :pointer) (umd-version :pointer)))

(com-on::define-comstruct dxgi-adapter-1
  (set-private-data com-on::hresult (name :pointer) (data-size :uint) (data :pointer))
  (set-private-data-interface com-on::hresult (name :pointer) (unknown :pointer))
  (private-data com-on::hresult (name :pointer) (data-size :pointer) (data :pointer))
  (parent com-on::hresult (riid :pointer) (parent :pointer))
  (enum-outputs com-on::hresult (output-index :uint) (output :pointer))
  (description com-on::hresult (description :pointer))
  (check-interface-support com-on::hresult (interface-name :pointer) (umd-version :pointer))
  (description-1 com-on::hresult (description :pointer)))

(com-on::define-comstruct d3d-11-device-context
;;;;;;;;;;;;;
  (device :void (device :pointer))
  (private-data com-on::hresult (guid :pointer) (data-size :pointer) (data :pointer))
  (set-private-data com-on::hresult (guid :pointer) (data-size :uint) (data :pointer))
  (set-private-data-interface com-on::hresult (guid :pointer) (data :pointer))
  (set-vconstant-buffers :void (start-slot :uint) (num-buffers :uint) (constant-buffers :pointer))
  (set-pshader-resources :void (start-slot :uint) (num-views :uint) (shader-resource-views :pointer))
  (set-pshader :void (pixel-shader :pointer) (class-instances :pointer) (num-class-instances :uint))
  (set-psamplers :void (start-slot :uint) (num-samplers :uint) (samplers :pointer))
  (set-vshader :void (vertex-shader :pointer) (class-instances :pointer) (num-class-instances :uint))
  (draw-indexed :void (index-count :uint) (start-index-location :uint) (base-vertex-location :int))
  (draw :void (vertex-count :uint) (start-vertex-location :uint))
  (map com-on::hresult (resource :pointer) (subresource :uint) (map-type :pointer) (map-flags :uint) (mapped-resource :pointer))
  (unmap :void (resource :pointer) (subresource :uint))
  (set-pconstant-buffers (start-slot :uint) (num-buffers :uint) (constant-buffers :pointer))
  (set-iainput-layout :void (input-layout :pointer))
  (set-iavertex-buffers :void (start-slot :uint) (num-buffers :uint) (vertex-buffers :pointer) (strides :pointer) (offsets :pointer))
  (set-ia-index-buffer :void (index-buffer :pointer) (format :pointer) (offset :uint))
  (draw-indexed-instanced :void (index-count-per-instance :uint) (instance-count :uint) (start-index-location :uint) (base-vertex-location :int) (start-instance-location :uint))
  (draw-instanced :void (vertex-count-per-instance :uint) (instance-count :uint) (start-vertex-location :uint) (start-instance-location :uint))
  (set-gconstant-buffers :void (start-slot :uint) (num-buffers :uint) (constant-buffers :pointer))
  (set-gshader :void (shader :pointer) (class-instances :pointer) (num-class-instances :uint))
  (set-ia-primitive-topology :void (topology :pointer))
  (set-vshader-resources (start-slot :uint) (num-views :uint) (shader-resource-views :pointer))
  (set-vsamplers (start-slot :uint) (num-samplers :uint) (samplers :pointer))
  (begin :void (async :pointer))
  (end :void (async :pointer))
  (data com-on::hresult (async :pointer) (data :pointer) (data-size :uint) (data-flags :uint))
  (set-predication :void (predicate :pointer) (predicate-value :bool))
  (set-shader-resources :void (start-slot :uint) (num-views :uint) (shader-resource-views :pointer))
  (set-gsamplers :void (start-slot :uint) (num-samplers :uint) (samplers :pointer) )
  (set-omrender-targets :void (num-views :uint) (render-target-views :pointer) (depth-stencil-view :pointer))
  (set-omrender-targets-and-unordered-access-views :void (num-rtvs :uint) (render-target-views :pointer) (depth-stencil-view :pointer) (start-slot :uint) (num-uavs :uint) (unordered-access-views :pointer) (initial-counts :pointer))
  (set-omblend-state :void (blend-state :pointer) (blend-factor :pointer) (sample-mask :uint))
  (set-omdepth-stencil-state :void (depth-stencil-state :pointer) (stencil-ref :uint))
  (set-sotargets :void (num-buffers :uint) (so-targets :pointer) (offsets :pointer))
  (draw-auto :void)
  (draw-indexed-instanced-indirect :void (buffer-for-args :pointer) (aligned-byte-offset-for-args :uint))
  (draw-instanced-indirect :void (buffer-for-args :pointer) (aligned-byte-offset-for-args :uint))
  (dispatch :void (count-x :uint) (count-y :uint) (count-z :uint))
  (dispatch-indirect :void (buffer-for-args :pointer) (aligned-byte-offset-for-args :uint))
  (set-rsstate :void (rasterizer-state :pointer))
  (set-rsviewports :void (num-viewports :uint) (viewports :pointer))
  (set-rsscissor-rects :void (num-rects :uint) (rects :pointer))
  (copy-subresource-region :void (destination-resource :pointer) (destination-subresource :uint) (destination-x :uint) (destination-y :uint) (destination-z :uint) (source-resource :pointer) (source-subresource :uint)
                           (source-box :pointer))
  (copy-resource :void (destination-resource :pointer) (source-resource :pointer)))
  
  
;;   void ( STDMETHODCALLTYPE *UpdateSubresource )( 
;;                                                 ID3D11DeviceContext * This,
;;                                                 /* [annotation] */ 
;;                                                 _In_  ID3D11Resource *pDstResource,
;;                                                 /* [annotation] */ 
;;                                                 _In_  UINT DstSubresource,
;;                                                 /* [annotation] */ 
;;                                                 _In_opt_  const D3D11_BOX *pDstBox,
;;                                                 /* [annotation] */ 
;;                                                 _In_  const void *pSrcData,
;;                                                 /* [annotation] */ 
;;                                                 _In_  UINT SrcRowPitch,
;;                                                 /* [annotation] */ 
;;                                                 _In_  UINT SrcDepthPitch);
  
;;   void ( STDMETHODCALLTYPE *CopyStructureCount )( 
;;                                                  ID3D11DeviceContext * This,
;;                                                  /* [annotation] */ 
;;                                                  _In_  ID3D11Buffer *pDstBuffer,
;;                                                  /* [annotation] */ 
;;                                                  _In_  UINT DstAlignedByteOffset,
;;                                                  /* [annotation] */ 
;;                                                  _In_  ID3D11UnorderedAccessView *pSrcView);
  
;;   void ( STDMETHODCALLTYPE *ClearRenderTargetView )( 
;;                                                     ID3D11DeviceContext * This,
;;                                                     /* [annotation] */ 
;;                                                     _In_  ID3D11RenderTargetView *pRenderTargetView,
;;                                                     /* [annotation] */ 
;;                                                     _In_  const FLOAT ColorRGBA[ 4 ]);
  
;;   void ( STDMETHODCALLTYPE *ClearUnorderedAccessViewUint )( 
;;                                                            ID3D11DeviceContext * This,
;;                                                            /* [annotation] */ 
;;                                                            _In_  ID3D11UnorderedAccessView *pUnorderedAccessView,
;;                                                            /* [annotation] */ 
;;                                                            _In_  const UINT Values[ 4 ]);
  
;;   void ( STDMETHODCALLTYPE *ClearUnorderedAccessViewFloat )( 
;;                                                             ID3D11DeviceContext * This,
;;                                                             /* [annotation] */ 
;;                                                             _In_  ID3D11UnorderedAccessView *pUnorderedAccessView,
;;                                                             /* [annotation] */ 
;;                                                             _In_  const FLOAT Values[ 4 ]);
  
;;   void ( STDMETHODCALLTYPE *ClearDepthStencilView )( 
;;                                                     ID3D11DeviceContext * This,
;;                                                     /* [annotation] */ 
;;                                                     _In_  ID3D11DepthStencilView *pDepthStencilView,
;;                                                     /* [annotation] */ 
;;                                                     _In_  UINT ClearFlags,
;;                                                     /* [annotation] */ 
;;                                                     _In_  FLOAT Depth,
;;                                                     /* [annotation] */ 
;;                                                     _In_  UINT8 Stencil);
  
;;   void ( STDMETHODCALLTYPE *GenerateMips )( 
;;                                            ID3D11DeviceContext * This,
;;                                            /* [annotation] */ 
;;                                            _In_  ID3D11ShaderResourceView *pShaderResourceView);
  
;;   void ( STDMETHODCALLTYPE *SetResourceMinLOD )( 
;;                                                 ID3D11DeviceContext * This,
;;                                                 /* [annotation] */ 
;;                                                 _In_  ID3D11Resource *pResource,
;;                                                 FLOAT MinLOD);
  
;;   FLOAT ( STDMETHODCALLTYPE *GetResourceMinLOD )( 
;;                                                  ID3D11DeviceContext * This,
;;                                                  /* [annotation] */ 
;;                                                  _In_  ID3D11Resource *pResource);
  
;;   void ( STDMETHODCALLTYPE *ResolveSubresource )( 
;;                                                  ID3D11DeviceContext * This,
;;                                                  /* [annotation] */ 
;;                                                  _In_  ID3D11Resource *pDstResource,
;;                                                  /* [annotation] */ 
;;                                                  _In_  UINT DstSubresource,
;;                                                  /* [annotation] */ 
;;                                                  _In_  ID3D11Resource *pSrcResource,
;;                                                  /* [annotation] */ 
;;                                                  _In_  UINT SrcSubresource,
;;                                                  /* [annotation] */ 
;;                                                  _In_  DXGI_FORMAT Format);
  
;;   void ( STDMETHODCALLTYPE *ExecuteCommandList )( 
;;                                                  ID3D11DeviceContext * This,
;;                                                  /* [annotation] */ 
;;                                                  _In_  ID3D11CommandList *pCommandList,
;;                                                  BOOL RestoreContextState);
  
;;   void ( STDMETHODCALLTYPE *HSSetShaderResources )( 
;;                                                    ID3D11DeviceContext * This,
;;                                                    /* [annotation] */ 
;;                                                    _In_range_( 0, D3D11_COMMONSHADER_INPUT_RESOURCE_SLOT_COUNT - 1 )  UINT StartSlot,
;;                                                    /* [annotation] */ 
;;                                                    _In_range_( 0, D3D11_COMMONSHADER_INPUT_RESOURCE_SLOT_COUNT - StartSlot )  UINT NumViews,
;;                                                    /* [annotation] */ 
;;                                                    _In_reads_opt_(NumViews)  ID3D11ShaderResourceView *const *ppShaderResourceViews);
  
;;   void ( STDMETHODCALLTYPE *HSSetShader )( 
;;                                           ID3D11DeviceContext * This,
;;                                           /* [annotation] */ 
;;                                           _In_opt_  ID3D11HullShader *pHullShader,
;;                                           /* [annotation] */ 
;;                                           _In_reads_opt_(NumClassInstances)  ID3D11ClassInstance *const *ppClassInstances,
;;                                           UINT NumClassInstances);
  
;;   void ( STDMETHODCALLTYPE *HSSetSamplers )( 
;;                                             ID3D11DeviceContext * This,
;;                                             /* [annotation] */ 
;;                                             _In_range_( 0, D3D11_COMMONSHADER_SAMPLER_SLOT_COUNT - 1 )  UINT StartSlot,
;;                                             /* [annotation] */ 
;;                                             _In_range_( 0, D3D11_COMMONSHADER_SAMPLER_SLOT_COUNT - StartSlot )  UINT NumSamplers,
;;                                             /* [annotation] */ 
;;                                             _In_reads_opt_(NumSamplers)  ID3D11SamplerState *const *ppSamplers);
  
;;   void ( STDMETHODCALLTYPE *HSSetConstantBuffers )( 
;;                                                    ID3D11DeviceContext * This,
;;                                                    /* [annotation] */ 
;;                                                    _In_range_( 0, D3D11_COMMONSHADER_CONSTANT_BUFFER_API_SLOT_COUNT - 1 )  UINT StartSlot,
;;                                                    /* [annotation] */ 
;;                                                    _In_range_( 0, D3D11_COMMONSHADER_CONSTANT_BUFFER_API_SLOT_COUNT - StartSlot )  UINT NumBuffers,
;;                                                    /* [annotation] */ 
;;                                                    _In_reads_opt_(NumBuffers)  ID3D11Buffer *const *ppConstantBuffers);
  
;;   void ( STDMETHODCALLTYPE *DSSetShaderResources )( 
;;                                                    ID3D11DeviceContext * This,
;;                                                    /* [annotation] */ 
;;                                                    _In_range_( 0, D3D11_COMMONSHADER_INPUT_RESOURCE_SLOT_COUNT - 1 )  UINT StartSlot,
;;                                                    /* [annotation] */ 
;;                                                    _In_range_( 0, D3D11_COMMONSHADER_INPUT_RESOURCE_SLOT_COUNT - StartSlot )  UINT NumViews,
;;                                                    /* [annotation] */ 
;;                                                    _In_reads_opt_(NumViews)  ID3D11ShaderResourceView *const *ppShaderResourceViews);
  
;;   void ( STDMETHODCALLTYPE *DSSetShader )( 
;;                                           ID3D11DeviceContext * This,
;;                                           /* [annotation] */ 
;;                                           _In_opt_  ID3D11DomainShader *pDomainShader,
;;                                           /* [annotation] */ 
;;                                           _In_reads_opt_(NumClassInstances)  ID3D11ClassInstance *const *ppClassInstances,
;;                                           UINT NumClassInstances);
  
;;   void ( STDMETHODCALLTYPE *DSSetSamplers )( 
;;                                             ID3D11DeviceContext * This,
;;                                             /* [annotation] */ 
;;                                             _In_range_( 0, D3D11_COMMONSHADER_SAMPLER_SLOT_COUNT - 1 )  UINT StartSlot,
;;                                             /* [annotation] */ 
;;                                             _In_range_( 0, D3D11_COMMONSHADER_SAMPLER_SLOT_COUNT - StartSlot )  UINT NumSamplers,
;;                                             /* [annotation] */ 
;;                                             _In_reads_opt_(NumSamplers)  ID3D11SamplerState *const *ppSamplers);
  
;;   void ( STDMETHODCALLTYPE *DSSetConstantBuffers )( 
;;                                                    ID3D11DeviceContext * This,
;;                                                    /* [annotation] */ 
;;                                                    _In_range_( 0, D3D11_COMMONSHADER_CONSTANT_BUFFER_API_SLOT_COUNT - 1 )  UINT StartSlot,
;;                                                    /* [annotation] */ 
;;                                                    _In_range_( 0, D3D11_COMMONSHADER_CONSTANT_BUFFER_API_SLOT_COUNT - StartSlot )  UINT NumBuffers,
;;                                                    /* [annotation] */ 
;;                                                    _In_reads_opt_(NumBuffers)  ID3D11Buffer *const *ppConstantBuffers);
  
;;   void ( STDMETHODCALLTYPE *CSSetShaderResources )( 
;;                                                    ID3D11DeviceContext * This,
;;                                                    /* [annotation] */ 
;;                                                    _In_range_( 0, D3D11_COMMONSHADER_INPUT_RESOURCE_SLOT_COUNT - 1 )  UINT StartSlot,
;;                                                    /* [annotation] */ 
;;                                                    _In_range_( 0, D3D11_COMMONSHADER_INPUT_RESOURCE_SLOT_COUNT - StartSlot )  UINT NumViews,
;;                                                    /* [annotation] */ 
;;                                                    _In_reads_opt_(NumViews)  ID3D11ShaderResourceView *const *ppShaderResourceViews);
  
;;   void ( STDMETHODCALLTYPE *CSSetUnorderedAccessViews )( 
;;                                                         ID3D11DeviceContext * This,
;;                                                         /* [annotation] */ 
;;                                                         _In_range_( 0, D3D11_1_UAV_SLOT_COUNT - 1 )  UINT StartSlot,
;;                                                         /* [annotation] */ 
;;                                                         _In_range_( 0, D3D11_1_UAV_SLOT_COUNT - StartSlot )  UINT NumUAVs,
;;                                                         /* [annotation] */ 
;;                                                         _In_reads_opt_(NumUAVs)  ID3D11UnorderedAccessView *const *ppUnorderedAccessViews,
;;                                                         /* [annotation] */ 
;;                                                         _In_reads_opt_(NumUAVs)  const UINT *pUAVInitialCounts);
  
;;   void ( STDMETHODCALLTYPE *CSSetShader )( 
;;                                           ID3D11DeviceContext * This,
;;                                           /* [annotation] */ 
;;                                           _In_opt_  ID3D11ComputeShader *pComputeShader,
;;                                           /* [annotation] */ 
;;                                           _In_reads_opt_(NumClassInstances)  ID3D11ClassInstance *const *ppClassInstances,
;;                                           UINT NumClassInstances);
  
;;   void ( STDMETHODCALLTYPE *CSSetSamplers )( 
;;                                             ID3D11DeviceContext * This,
;;                                             /* [annotation] */ 
;;                                             _In_range_( 0, D3D11_COMMONSHADER_SAMPLER_SLOT_COUNT - 1 )  UINT StartSlot,
;;                                             /* [annotation] */ 
;;                                             _In_range_( 0, D3D11_COMMONSHADER_SAMPLER_SLOT_COUNT - StartSlot )  UINT NumSamplers,
;;                                             /* [annotation] */ 
;;                                             _In_reads_opt_(NumSamplers)  ID3D11SamplerState *const *ppSamplers);
  
;;   void ( STDMETHODCALLTYPE *CSSetConstantBuffers )( 
;;                                                    ID3D11DeviceContext * This,
;;                                                    /* [annotation] */ 
;;                                                    _In_range_( 0, D3D11_COMMONSHADER_CONSTANT_BUFFER_API_SLOT_COUNT - 1 )  UINT StartSlot,
;;                                                    /* [annotation] */ 
;;                                                    _In_range_( 0, D3D11_COMMONSHADER_CONSTANT_BUFFER_API_SLOT_COUNT - StartSlot )  UINT NumBuffers,
;;                                                    /* [annotation] */ 
;;                                                    _In_reads_opt_(NumBuffers)  ID3D11Buffer *const *ppConstantBuffers);
  
;;   void ( STDMETHODCALLTYPE *VSGetConstantBuffers )( 
;;                                                    ID3D11DeviceContext * This,
;;                                                    /* [annotation] */ 
;;                                                    _In_range_( 0, D3D11_COMMONSHADER_CONSTANT_BUFFER_API_SLOT_COUNT - 1 )  UINT StartSlot,
;;                                                    /* [annotation] */ 
;;                                                    _In_range_( 0, D3D11_COMMONSHADER_CONSTANT_BUFFER_API_SLOT_COUNT - StartSlot )  UINT NumBuffers,
;;                                                    /* [annotation] */ 
;;                                                    _Out_writes_opt_(NumBuffers)  ID3D11Buffer **ppConstantBuffers);
  
;;   void ( STDMETHODCALLTYPE *PSGetShaderResources )( 
;;                                                    ID3D11DeviceContext * This,
;;                                                    /* [annotation] */ 
;;                                                    _In_range_( 0, D3D11_COMMONSHADER_INPUT_RESOURCE_SLOT_COUNT - 1 )  UINT StartSlot,
;;                                                    /* [annotation] */ 
;;                                                    _In_range_( 0, D3D11_COMMONSHADER_INPUT_RESOURCE_SLOT_COUNT - StartSlot )  UINT NumViews,
;;                                                    /* [annotation] */ 
;;                                                    _Out_writes_opt_(NumViews)  ID3D11ShaderResourceView **ppShaderResourceViews);
  
;;   void ( STDMETHODCALLTYPE *PSGetShader )( 
;;                                           ID3D11DeviceContext * This,
;;                                           /* [annotation] */ 
;;                                           _Outptr_result_maybenull_  ID3D11PixelShader **ppPixelShader,
;;                                           /* [annotation] */ 
;;                                           _Out_writes_opt_(*pNumClassInstances)  ID3D11ClassInstance **ppClassInstances,
;;                                           /* [annotation] */ 
;;                                           _Inout_opt_  UINT *pNumClassInstances);
  
;;   void ( STDMETHODCALLTYPE *PSGetSamplers )( 
;;                                             ID3D11DeviceContext * This,
;;                                             /* [annotation] */ 
;;                                             _In_range_( 0, D3D11_COMMONSHADER_SAMPLER_SLOT_COUNT - 1 )  UINT StartSlot,
;;                                             /* [annotation] */ 
;;                                             _In_range_( 0, D3D11_COMMONSHADER_SAMPLER_SLOT_COUNT - StartSlot )  UINT NumSamplers,
;;                                             /* [annotation] */ 
;;                                             _Out_writes_opt_(NumSamplers)  ID3D11SamplerState **ppSamplers);
  
;;   void ( STDMETHODCALLTYPE *VSGetShader )( 
;;                                           ID3D11DeviceContext * This,
;;                                           /* [annotation] */ 
;;                                           _Outptr_result_maybenull_  ID3D11VertexShader **ppVertexShader,
;;                                           /* [annotation] */ 
;;                                           _Out_writes_opt_(*pNumClassInstances)  ID3D11ClassInstance **ppClassInstances,
;;                                           /* [annotation] */ 
;;                                           _Inout_opt_  UINT *pNumClassInstances);
  
;;   void ( STDMETHODCALLTYPE *PSGetConstantBuffers )( 
;;                                                    ID3D11DeviceContext * This,
;;                                                    /* [annotation] */ 
;;                                                    _In_range_( 0, D3D11_COMMONSHADER_CONSTANT_BUFFER_API_SLOT_COUNT - 1 )  UINT StartSlot,
;;                                                    /* [annotation] */ 
;;                                                    _In_range_( 0, D3D11_COMMONSHADER_CONSTANT_BUFFER_API_SLOT_COUNT - StartSlot )  UINT NumBuffers,
;;                                                    /* [annotation] */ 
;;                                                    _Out_writes_opt_(NumBuffers)  ID3D11Buffer **ppConstantBuffers);
  
;;   void ( STDMETHODCALLTYPE *IAGetInputLayout )( 
;;                                                ID3D11DeviceContext * This,
;;                                                /* [annotation] */ 
;;                                                _Outptr_result_maybenull_  ID3D11InputLayout **ppInputLayout);
  
;;   void ( STDMETHODCALLTYPE *IAGetVertexBuffers )( 
;;                                                  ID3D11DeviceContext * This,
;;                                                  /* [annotation] */ 
;;                                                  _In_range_( 0, D3D11_IA_VERTEX_INPUT_RESOURCE_SLOT_COUNT - 1 )  UINT StartSlot,
;;                                                  /* [annotation] */ 
;;                                                  _In_range_( 0, D3D11_IA_VERTEX_INPUT_RESOURCE_SLOT_COUNT - StartSlot )  UINT NumBuffers,
;;                                                  /* [annotation] */ 
;;                                                  _Out_writes_opt_(NumBuffers)  ID3D11Buffer **ppVertexBuffers,
;;                                                  /* [annotation] */ 
;;                                                  _Out_writes_opt_(NumBuffers)  UINT *pStrides,
;;                                                  /* [annotation] */ 
;;                                                  _Out_writes_opt_(NumBuffers)  UINT *pOffsets);
  
;;   void ( STDMETHODCALLTYPE *IAGetIndexBuffer )( 
;;                                                ID3D11DeviceContext * This,
;;                                                /* [annotation] */ 
;;                                                _Outptr_opt_result_maybenull_  ID3D11Buffer **pIndexBuffer,
;;                                                /* [annotation] */ 
;;                                                _Out_opt_  DXGI_FORMAT *Format,
;;                                                /* [annotation] */ 
;;                                                _Out_opt_  UINT *Offset);
  
;;   void ( STDMETHODCALLTYPE *GSGetConstantBuffers )( 
;;                                                    ID3D11DeviceContext * This,
;;                                                    /* [annotation] */ 
;;                                                    _In_range_( 0, D3D11_COMMONSHADER_CONSTANT_BUFFER_API_SLOT_COUNT - 1 )  UINT StartSlot,
;;                                                    /* [annotation] */ 
;;                                                    _In_range_( 0, D3D11_COMMONSHADER_CONSTANT_BUFFER_API_SLOT_COUNT - StartSlot )  UINT NumBuffers,
;;                                                    /* [annotation] */ 
;;                                                    _Out_writes_opt_(NumBuffers)  ID3D11Buffer **ppConstantBuffers);
  
;;   void ( STDMETHODCALLTYPE *GSGetShader )( 
;;                                           ID3D11DeviceContext * This,
;;                                           /* [annotation] */ 
;;                                           _Outptr_result_maybenull_  ID3D11GeometryShader **ppGeometryShader,
;;                                           /* [annotation] */ 
;;                                           _Out_writes_opt_(*pNumClassInstances)  ID3D11ClassInstance **ppClassInstances,
;;                                           /* [annotation] */ 
;;                                           _Inout_opt_  UINT *pNumClassInstances);
  
;;   void ( STDMETHODCALLTYPE *IAGetPrimitiveTopology )( 
;;                                                      ID3D11DeviceContext * This,
;;                                                      /* [annotation] */ 
;;                                                      _Out_  D3D11_PRIMITIVE_TOPOLOGY *pTopology);
  
;;   void ( STDMETHODCALLTYPE *VSGetShaderResources )( 
;;                                                    ID3D11DeviceContext * This,
;;                                                    /* [annotation] */ 
;;                                                    _In_range_( 0, D3D11_COMMONSHADER_INPUT_RESOURCE_SLOT_COUNT - 1 )  UINT StartSlot,
;;                                                    /* [annotation] */ 
;;                                                    _In_range_( 0, D3D11_COMMONSHADER_INPUT_RESOURCE_SLOT_COUNT - StartSlot )  UINT NumViews,
;;                                                    /* [annotation] */ 
;;                                                    _Out_writes_opt_(NumViews)  ID3D11ShaderResourceView **ppShaderResourceViews);
  
;;   void ( STDMETHODCALLTYPE *VSGetSamplers )( 
;;                                             ID3D11DeviceContext * This,
;;                                             /* [annotation] */ 
;;                                             _In_range_( 0, D3D11_COMMONSHADER_SAMPLER_SLOT_COUNT - 1 )  UINT StartSlot,
;;                                             /* [annotation] */ 
;;                                             _In_range_( 0, D3D11_COMMONSHADER_SAMPLER_SLOT_COUNT - StartSlot )  UINT NumSamplers,
;;                                             /* [annotation] */ 
;;                                             _Out_writes_opt_(NumSamplers)  ID3D11SamplerState **ppSamplers);
  
;;   void ( STDMETHODCALLTYPE *GetPredication )( 
;;                                              ID3D11DeviceContext * This,
;;                                              /* [annotation] */ 
;;                                              _Outptr_opt_result_maybenull_  ID3D11Predicate **ppPredicate,
;;                                              /* [annotation] */ 
;;                                              _Out_opt_  BOOL *pPredicateValue);
  
;;   void ( STDMETHODCALLTYPE *GSGetShaderResources )( 
;;                                                    ID3D11DeviceContext * This,
;;                                                    /* [annotation] */ 
;;                                                    _In_range_( 0, D3D11_COMMONSHADER_INPUT_RESOURCE_SLOT_COUNT - 1 )  UINT StartSlot,
;;                                                    /* [annotation] */ 
;;                                                    _In_range_( 0, D3D11_COMMONSHADER_INPUT_RESOURCE_SLOT_COUNT - StartSlot )  UINT NumViews,
;;                                                    /* [annotation] */ 
;;                                                    _Out_writes_opt_(NumViews)  ID3D11ShaderResourceView **ppShaderResourceViews);
  
;;   void ( STDMETHODCALLTYPE *GSGetSamplers )( 
;;                                             ID3D11DeviceContext * This,
;;                                             /* [annotation] */ 
;;                                             _In_range_( 0, D3D11_COMMONSHADER_SAMPLER_SLOT_COUNT - 1 )  UINT StartSlot,
;;                                             /* [annotation] */ 
;;                                             _In_range_( 0, D3D11_COMMONSHADER_SAMPLER_SLOT_COUNT - StartSlot )  UINT NumSamplers,
;;                                             /* [annotation] */ 
;;                                             _Out_writes_opt_(NumSamplers)  ID3D11SamplerState **ppSamplers);
  
;;   void ( STDMETHODCALLTYPE *OMGetRenderTargets )( 
;;                                                  ID3D11DeviceContext * This,
;;                                                  /* [annotation] */ 
;;                                                  _In_range_( 0, D3D11_SIMULTANEOUS_RENDER_TARGET_COUNT )  UINT NumViews,
;;                                                  /* [annotation] */ 
;;                                                  _Out_writes_opt_(NumViews)  ID3D11RenderTargetView **ppRenderTargetViews,
;;                                                  /* [annotation] */ 
;;                                                  _Outptr_opt_result_maybenull_  ID3D11DepthStencilView **ppDepthStencilView);
  
;;   void ( STDMETHODCALLTYPE *OMGetRenderTargetsAndUnorderedAccessViews )( 
;;                                                                         ID3D11DeviceContext * This,
;;                                                                         /* [annotation] */ 
;;                                                                         _In_range_( 0, D3D11_SIMULTANEOUS_RENDER_TARGET_COUNT )  UINT NumRTVs,
;;                                                                         /* [annotation] */ 
;;                                                                         _Out_writes_opt_(NumRTVs)  ID3D11RenderTargetView **ppRenderTargetViews,
;;                                                                         /* [annotation] */ 
;;                                                                         _Outptr_opt_result_maybenull_  ID3D11DepthStencilView **ppDepthStencilView,
;;                                                                         /* [annotation] */ 
;;                                                                         _In_range_( 0, D3D11_PS_CS_UAV_REGISTER_COUNT - 1 )  UINT UAVStartSlot,
;;                                                                         /* [annotation] */ 
;;                                                                         _In_range_( 0, D3D11_PS_CS_UAV_REGISTER_COUNT - UAVStartSlot )  UINT NumUAVs,
;;                                                                         /* [annotation] */ 
;;                                                                         _Out_writes_opt_(NumUAVs)  ID3D11UnorderedAccessView **ppUnorderedAccessViews);
  
;;   void ( STDMETHODCALLTYPE *OMGetBlendState )( 
;;                                               ID3D11DeviceContext * This,
;;                                               /* [annotation] */ 
;;                                               _Outptr_opt_result_maybenull_  ID3D11BlendState **ppBlendState,
;;                                               /* [annotation] */ 
;;                                               _Out_opt_  FLOAT BlendFactor[ 4 ],
;;                                               /* [annotation] */ 
;;                                               _Out_opt_  UINT *pSampleMask);
  
;;   void ( STDMETHODCALLTYPE *OMGetDepthStencilState )( 
;;                                                      ID3D11DeviceContext * This,
;;                                                      /* [annotation] */ 
;;                                                      _Outptr_opt_result_maybenull_  ID3D11DepthStencilState **ppDepthStencilState,
;;                                                      /* [annotation] */ 
;;                                                      _Out_opt_  UINT *pStencilRef);
  
;;   void ( STDMETHODCALLTYPE *SOGetTargets )( 
;;                                            ID3D11DeviceContext * This,
;;                                            /* [annotation] */ 
;;                                            _In_range_( 0, D3D11_SO_BUFFER_SLOT_COUNT )  UINT NumBuffers,
;;                                            /* [annotation] */ 
;;                                            _Out_writes_opt_(NumBuffers)  ID3D11Buffer **ppSOTargets);
  
;;   void ( STDMETHODCALLTYPE *RSGetState )( 
;;                                          ID3D11DeviceContext * This,
;;                                          /* [annotation] */ 
;;                                          _Outptr_result_maybenull_  ID3D11RasterizerState **ppRasterizerState);
  
;;   void ( STDMETHODCALLTYPE *RSGetViewports )( 
;;                                              ID3D11DeviceContext * This,
;;                                              /* [annotation] */ 
;;                                              _Inout_ /*_range(0, D3D11_VIEWPORT_AND_SCISSORRECT_OBJECT_COUNT_PER_PIPELINE )*/   UINT *pNumViewports,
;;                                              /* [annotation] */ 
;;                                              _Out_writes_opt_(*pNumViewports)  D3D11_VIEWPORT *pViewports);
  
;;   void ( STDMETHODCALLTYPE *RSGetScissorRects )( 
;;                                                 ID3D11DeviceContext * This,
;;                                                 /* [annotation] */ 
;;                                                 _Inout_ /*_range(0, D3D11_VIEWPORT_AND_SCISSORRECT_OBJECT_COUNT_PER_PIPELINE )*/   UINT *pNumRects,
;;                                                 /* [annotation] */ 
;;                                                 _Out_writes_opt_(*pNumRects)  D3D11_RECT *pRects);
  
;;   void ( STDMETHODCALLTYPE *HSGetShaderResources )( 
;;                                                    ID3D11DeviceContext * This,
;;                                                    /* [annotation] */ 
;;                                                    _In_range_( 0, D3D11_COMMONSHADER_INPUT_RESOURCE_SLOT_COUNT - 1 )  UINT StartSlot,
;;                                                    /* [annotation] */ 
;;                                                    _In_range_( 0, D3D11_COMMONSHADER_INPUT_RESOURCE_SLOT_COUNT - StartSlot )  UINT NumViews,
;;                                                    /* [annotation] */ 
;;                                                    _Out_writes_opt_(NumViews)  ID3D11ShaderResourceView **ppShaderResourceViews);
  
;;   void ( STDMETHODCALLTYPE *HSGetShader )( 
;;                                           ID3D11DeviceContext * This,
;;                                           /* [annotation] */ 
;;                                           _Outptr_result_maybenull_  ID3D11HullShader **ppHullShader,
;;                                           /* [annotation] */ 
;;                                           _Out_writes_opt_(*pNumClassInstances)  ID3D11ClassInstance **ppClassInstances,
;;                                           /* [annotation] */ 
;;                                           _Inout_opt_  UINT *pNumClassInstances);
  
;;   void ( STDMETHODCALLTYPE *HSGetSamplers )( 
;;                                             ID3D11DeviceContext * This,
;;                                             /* [annotation] */ 
;;                                             _In_range_( 0, D3D11_COMMONSHADER_SAMPLER_SLOT_COUNT - 1 )  UINT StartSlot,
;;                                             /* [annotation] */ 
;;                                             _In_range_( 0, D3D11_COMMONSHADER_SAMPLER_SLOT_COUNT - StartSlot )  UINT NumSamplers,
;;                                             /* [annotation] */ 
;;                                             _Out_writes_opt_(NumSamplers)  ID3D11SamplerState **ppSamplers);
  
;;   void ( STDMETHODCALLTYPE *HSGetConstantBuffers )( 
;;                                                    ID3D11DeviceContext * This,
;;                                                    /* [annotation] */ 
;;                                                    _In_range_( 0, D3D11_COMMONSHADER_CONSTANT_BUFFER_API_SLOT_COUNT - 1 )  UINT StartSlot,
;;                                                    /* [annotation] */ 
;;                                                    _In_range_( 0, D3D11_COMMONSHADER_CONSTANT_BUFFER_API_SLOT_COUNT - StartSlot )  UINT NumBuffers,
;;                                                    /* [annotation] */ 
;;                                                    _Out_writes_opt_(NumBuffers)  ID3D11Buffer **ppConstantBuffers);
  
;;   void ( STDMETHODCALLTYPE *DSGetShaderResources )( 
;;                                                    ID3D11DeviceContext * This,
;;                                                    /* [annotation] */ 
;;                                                    _In_range_( 0, D3D11_COMMONSHADER_INPUT_RESOURCE_SLOT_COUNT - 1 )  UINT StartSlot,
;;                                                    /* [annotation] */ 
;;                                                    _In_range_( 0, D3D11_COMMONSHADER_INPUT_RESOURCE_SLOT_COUNT - StartSlot )  UINT NumViews,
;;                                                    /* [annotation] */ 
;;                                                    _Out_writes_opt_(NumViews)  ID3D11ShaderResourceView **ppShaderResourceViews);
  
;;   void ( STDMETHODCALLTYPE *DSGetShader )( 
;;                                           ID3D11DeviceContext * This,
;;                                           /* [annotation] */ 
;;                                           _Outptr_result_maybenull_  ID3D11DomainShader **ppDomainShader,
;;                                           /* [annotation] */ 
;;                                           _Out_writes_opt_(*pNumClassInstances)  ID3D11ClassInstance **ppClassInstances,
;;                                           /* [annotation] */ 
;;                                           _Inout_opt_  UINT *pNumClassInstances);
  
;;   void ( STDMETHODCALLTYPE *DSGetSamplers )( 
;;                                             ID3D11DeviceContext * This,
;;                                             /* [annotation] */ 
;;                                             _In_range_( 0, D3D11_COMMONSHADER_SAMPLER_SLOT_COUNT - 1 )  UINT StartSlot,
;;                                             /* [annotation] */ 
;;                                             _In_range_( 0, D3D11_COMMONSHADER_SAMPLER_SLOT_COUNT - StartSlot )  UINT NumSamplers,
;;                                             /* [annotation] */ 
;;                                             _Out_writes_opt_(NumSamplers)  ID3D11SamplerState **ppSamplers);
  
;;   void ( STDMETHODCALLTYPE *DSGetConstantBuffers )( 
;;                                                    ID3D11DeviceContext * This,
;;                                                    /* [annotation] */ 
;;                                                    _In_range_( 0, D3D11_COMMONSHADER_CONSTANT_BUFFER_API_SLOT_COUNT - 1 )  UINT StartSlot,
;;                                                    /* [annotation] */ 
;;                                                    _In_range_( 0, D3D11_COMMONSHADER_CONSTANT_BUFFER_API_SLOT_COUNT - StartSlot )  UINT NumBuffers,
;;                                                    /* [annotation] */ 
;;                                                    _Out_writes_opt_(NumBuffers)  ID3D11Buffer **ppConstantBuffers);
  
;;   void ( STDMETHODCALLTYPE *CSGetShaderResources )( 
;;                                                    ID3D11DeviceContext * This,
;;                                                    /* [annotation] */ 
;;                                                    _In_range_( 0, D3D11_COMMONSHADER_INPUT_RESOURCE_SLOT_COUNT - 1 )  UINT StartSlot,
;;                                                    /* [annotation] */ 
;;                                                    _In_range_( 0, D3D11_COMMONSHADER_INPUT_RESOURCE_SLOT_COUNT - StartSlot )  UINT NumViews,
;;                                                    /* [annotation] */ 
;;                                                    _Out_writes_opt_(NumViews)  ID3D11ShaderResourceView **ppShaderResourceViews);
  
;;   void ( STDMETHODCALLTYPE *CSGetUnorderedAccessViews )( 
;;                                                         ID3D11DeviceContext * This,
;;                                                         /* [annotation] */ 
;;                                                         _In_range_( 0, D3D11_1_UAV_SLOT_COUNT - 1 )  UINT StartSlot,
;;                                                         /* [annotation] */ 
;;                                                         _In_range_( 0, D3D11_1_UAV_SLOT_COUNT - StartSlot )  UINT NumUAVs,
;;                                                         /* [annotation] */ 
;;                                                         _Out_writes_opt_(NumUAVs)  ID3D11UnorderedAccessView **ppUnorderedAccessViews);
  
;;   void ( STDMETHODCALLTYPE *CSGetShader )( 
;;                                           ID3D11DeviceContext * This,
;;                                           /* [annotation] */ 
;;                                           _Outptr_result_maybenull_  ID3D11ComputeShader **ppComputeShader,
;;                                           /* [annotation] */ 
;;                                           _Out_writes_opt_(*pNumClassInstances)  ID3D11ClassInstance **ppClassInstances,
;;                                           /* [annotation] */ 
;;                                           _Inout_opt_  UINT *pNumClassInstances);
  
;;   void ( STDMETHODCALLTYPE *CSGetSamplers )( 
;;                                             ID3D11DeviceContext * This,
;;                                             /* [annotation] */ 
;;                                             _In_range_( 0, D3D11_COMMONSHADER_SAMPLER_SLOT_COUNT - 1 )  UINT StartSlot,
;;                                             /* [annotation] */ 
;;                                             _In_range_( 0, D3D11_COMMONSHADER_SAMPLER_SLOT_COUNT - StartSlot )  UINT NumSamplers,
;;                                             /* [annotation] */ 
;;                                             _Out_writes_opt_(NumSamplers)  ID3D11SamplerState **ppSamplers);
  
;;   void ( STDMETHODCALLTYPE *CSGetConstantBuffers )( 
;;                                                    ID3D11DeviceContext * This,
;;                                                    /* [annotation] */ 
;;                                                    _In_range_( 0, D3D11_COMMONSHADER_CONSTANT_BUFFER_API_SLOT_COUNT - 1 )  UINT StartSlot,
;;                                                    /* [annotation] */ 
;;                                                    _In_range_( 0, D3D11_COMMONSHADER_CONSTANT_BUFFER_API_SLOT_COUNT - StartSlot )  UINT NumBuffers,
;;                                                    /* [annotation] */ 
;;                                                    _Out_writes_opt_(NumBuffers)  ID3D11Buffer **ppConstantBuffers);
  
;;   void ( STDMETHODCALLTYPE *ClearState )( 
;;                                          ID3D11DeviceContext * This);
  
;;   void ( STDMETHODCALLTYPE *Flush )( 
;;                                     ID3D11DeviceContext * This);
  
;;   D3D11_DEVICE_CONTEXT_TYPE ( STDMETHODCALLTYPE *GetType )( 
;;                                                            ID3D11DeviceContext * This);
  
;;   UINT ( STDMETHODCALLTYPE *GetContextFlags )( 
;;                                               ID3D11DeviceContext * This);
  
;;   HRESULT ( STDMETHODCALLTYPE *FinishCommandList )( 
;;                                                    ID3D11DeviceContext * This,
;;                                                    BOOL RestoreDeferredContextState,
;;                                                    /* [annotation] */ 
;;                                                    _COM_Outptr_opt_  ID3D11CommandList **ppCommandList);
  
;;   END_INTERFACE
;;   } ID3D11DeviceContextVtbl;
;; ;;;;;;;;;;;;;
;;   )


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
(com-on::define-comstruct dxgi-resource
  (set-private-data com-on::hresult (name :pointer) (data-size :uint) (data :pointer))
  (set-private-data-interface com-on::hresult (name :pointer) (unknown :pointer))
  (private-data com-on::hresult (name :pointer) (data-size :pointer) (data :pointer))
  (parent com-on::hresult (riid :pointer) (parent :pointer))
  (device com-on::hresult (rrid :pointer) (device :pointer))
  (shared-handle com-on::hresult (shared-handle :pointer))
  (usage com-on::hresult (usage :pointer))
  (set-eviction-priority com-on::hresult (eviction-priority :uint))
  (eviction-priority com-on::hresult (eviction-priority :pointer)))

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

(defmethod cffi:translate-into-foreign-memory ((value list) (type dxgi-sample-tclass) pointer)
  (cffi:with-foreign-slots ((count quality) pointer (:struct dxgi-sample))
    (setf count (first value)
          quality (second value))))

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


(com-on::define-comstruct d3d-11-device
  (create-buffer com-on::hresult (desc :pointer) (initial-data :pointer) (buffer :pointer))
  (create-texture-1d com-on::hresult (desc :pointer) (initial-data :pointer) (texture-1d :pointer))
  (create-texture-2d com-on::hresult (desc :pointer) (initial-data :pointer) (texture-2d :pointer)))


;; HRESULT ( STDMETHODCALLTYPE *CreateTexture2D )( 
;;                                                ID3D11Device * This,
;;                                                /* [annotation] */ 
;;                                                _In_  const D3D11_TEXTURE2D_DESC *pDesc,
;;                                                /* [annotation] */ 
;;                                                _In_reads_opt_(_Inexpressible_(pDesc->MipLevels * pDesc->ArraySize))  const D3D11_SUBRESOURCE_DATA *pInitialData,
;;                                                /* [annotation] */ 
;;                                                _COM_Outptr_opt_  ID3D11Texture2D **ppTexture2D);

;; HRESULT ( STDMETHODCALLTYPE *CreateTexture3D )( 
;;                                                ID3D11Device * This,
;;                                                /* [annotation] */ 
;;                                                _In_  const D3D11_TEXTURE3D_DESC *pDesc,
;;                                                /* [annotation] */ 
;;                                                _In_reads_opt_(_Inexpressible_(pDesc->MipLevels))  const D3D11_SUBRESOURCE_DATA *pInitialData,
;;                                                /* [annotation] */ 
;;                                                _COM_Outptr_opt_  ID3D11Texture3D **ppTexture3D);

;; HRESULT ( STDMETHODCALLTYPE *CreateShaderResourceView )( 
;;                                                         ID3D11Device * This,
;;                                                         /* [annotation] */ 
;;                                                         _In_  ID3D11Resource *pResource,
;;                                                         /* [annotation] */ 
;;                                                         _In_opt_  const D3D11_SHADER_RESOURCE_VIEW_DESC *pDesc,
;;                                                         /* [annotation] */ 
;;                                                         _COM_Outptr_opt_  ID3D11ShaderResourceView **ppSRView);

;; HRESULT ( STDMETHODCALLTYPE *CreateUnorderedAccessView )( 
;;                                                          ID3D11Device * This,
;;                                                          /* [annotation] */ 
;;                                                          _In_  ID3D11Resource *pResource,
;;                                                          /* [annotation] */ 
;;                                                          _In_opt_  const D3D11_UNORDERED_ACCESS_VIEW_DESC *pDesc,
;;                                                          /* [annotation] */ 
;;                                                          _COM_Outptr_opt_  ID3D11UnorderedAccessView **ppUAView);

;; HRESULT ( STDMETHODCALLTYPE *CreateRenderTargetView )( 
;;                                                       ID3D11Device * This,
;;                                                       /* [annotation] */ 
;;                                                       _In_  ID3D11Resource *pResource,
;;                                                       /* [annotation] */ 
;;                                                       _In_opt_  const D3D11_RENDER_TARGET_VIEW_DESC *pDesc,
;;                                                       /* [annotation] */ 
;;                                                       _COM_Outptr_opt_  ID3D11RenderTargetView **ppRTView);

;; HRESULT ( STDMETHODCALLTYPE *CreateDepthStencilView )( 
;;                                                       ID3D11Device * This,
;;                                                       /* [annotation] */ 
;;                                                       _In_  ID3D11Resource *pResource,
;;                                                       /* [annotation] */ 
;;                                                       _In_opt_  const D3D11_DEPTH_STENCIL_VIEW_DESC *pDesc,
;;                                                       /* [annotation] */ 
;;                                                       _COM_Outptr_opt_  ID3D11DepthStencilView **ppDepthStencilView);

;; HRESULT ( STDMETHODCALLTYPE *CreateInputLayout )( 
;;                                                  ID3D11Device * This,
;;                                                  /* [annotation] */ 
;;                                                  _In_reads_(NumElements)  const D3D11_INPUT_ELEMENT_DESC *pInputElementDescs,
;;                                                  /* [annotation] */ 
;;                                                  _In_range_( 0, D3D11_IA_VERTEX_INPUT_STRUCTURE_ELEMENT_COUNT )  UINT NumElements,
;;                                                  /* [annotation] */ 
;;                                                  _In_reads_(BytecodeLength)  const void *pShaderBytecodeWithInputSignature,
;;                                                  /* [annotation] */ 
;;                                                  _In_  SIZE_T BytecodeLength,
;;                                                  /* [annotation] */ 
;;                                                  _COM_Outptr_opt_  ID3D11InputLayout **ppInputLayout);

;; HRESULT ( STDMETHODCALLTYPE *CreateVertexShader )( 
;;                                                   ID3D11Device * This,
;;                                                   /* [annotation] */ 
;;                                                   _In_reads_(BytecodeLength)  const void *pShaderBytecode,
;;                                                   /* [annotation] */ 
;;                                                   _In_  SIZE_T BytecodeLength,
;;                                                   /* [annotation] */ 
;;                                                   _In_opt_  ID3D11ClassLinkage *pClassLinkage,
;;                                                   /* [annotation] */ 
;;                                                   _COM_Outptr_opt_  ID3D11VertexShader **ppVertexShader);

;; HRESULT ( STDMETHODCALLTYPE *CreateGeometryShader )( 
;;                                                     ID3D11Device * This,
;;                                                     /* [annotation] */ 
;;                                                     _In_reads_(BytecodeLength)  const void *pShaderBytecode,
;;                                                     /* [annotation] */ 
;;                                                     _In_  SIZE_T BytecodeLength,
;;                                                     /* [annotation] */ 
;;                                                     _In_opt_  ID3D11ClassLinkage *pClassLinkage,
;;                                                     /* [annotation] */ 
;;                                                     _COM_Outptr_opt_  ID3D11GeometryShader **ppGeometryShader);

;; HRESULT ( STDMETHODCALLTYPE *CreateGeometryShaderWithStreamOutput )( 
;;                                                                     ID3D11Device * This,
;;                                                                     /* [annotation] */ 
;;                                                                     _In_reads_(BytecodeLength)  const void *pShaderBytecode,
;;                                                                     /* [annotation] */ 
;;                                                                     _In_  SIZE_T BytecodeLength,
;;                                                                     /* [annotation] */ 
;;                                                                     _In_reads_opt_(NumEntries)  const D3D11_SO_DECLARATION_ENTRY *pSODeclaration,
;;                                                                     /* [annotation] */ 
;;                                                                     _In_range_( 0, D3D11_SO_STREAM_COUNT * D3D11_SO_OUTPUT_COMPONENT_COUNT )  UINT NumEntries,
;;                                                                     /* [annotation] */ 
;;                                                                     _In_reads_opt_(NumStrides)  const UINT *pBufferStrides,
;;                                                                     /* [annotation] */ 
;;                                                                     _In_range_( 0, D3D11_SO_BUFFER_SLOT_COUNT )  UINT NumStrides,
;;                                                                     /* [annotation] */ 
;;                                                                     _In_  UINT RasterizedStream,
;;                                                                     /* [annotation] */ 
;;                                                                     _In_opt_  ID3D11ClassLinkage *pClassLinkage,
;;                                                                     /* [annotation] */ 
;;                                                                     _COM_Outptr_opt_  ID3D11GeometryShader **ppGeometryShader);

;; HRESULT ( STDMETHODCALLTYPE *CreatePixelShader )( 
;;                                                  ID3D11Device * This,
;;                                                  /* [annotation] */ 
;;                                                  _In_reads_(BytecodeLength)  const void *pShaderBytecode,
;;                                                  /* [annotation] */ 
;;                                                  _In_  SIZE_T BytecodeLength,
;;                                                  /* [annotation] */ 
;;                                                  _In_opt_  ID3D11ClassLinkage *pClassLinkage,
;;                                                  /* [annotation] */ 
;;                                                  _COM_Outptr_opt_  ID3D11PixelShader **ppPixelShader);

;; HRESULT ( STDMETHODCALLTYPE *CreateHullShader )( 
;;                                                 ID3D11Device * This,
;;                                                 /* [annotation] */ 
;;                                                 _In_reads_(BytecodeLength)  const void *pShaderBytecode,
;;                                                 /* [annotation] */ 
;;                                                 _In_  SIZE_T BytecodeLength,
;;                                                 /* [annotation] */ 
;;                                                 _In_opt_  ID3D11ClassLinkage *pClassLinkage,
;;                                                 /* [annotation] */ 
;;                                                 _COM_Outptr_opt_  ID3D11HullShader **ppHullShader);

;; HRESULT ( STDMETHODCALLTYPE *CreateDomainShader )( 
;;                                                   ID3D11Device * This,
;;                                                   /* [annotation] */ 
;;                                                   _In_reads_(BytecodeLength)  const void *pShaderBytecode,
;;                                                   /* [annotation] */ 
;;                                                   _In_  SIZE_T BytecodeLength,
;;                                                   /* [annotation] */ 
;;                                                   _In_opt_  ID3D11ClassLinkage *pClassLinkage,
;;                                                   /* [annotation] */ 
;;                                                   _COM_Outptr_opt_  ID3D11DomainShader **ppDomainShader);

;; HRESULT ( STDMETHODCALLTYPE *CreateComputeShader )( 
;;                                                    ID3D11Device * This,
;;                                                    /* [annotation] */ 
;;                                                    _In_reads_(BytecodeLength)  const void *pShaderBytecode,
;;                                                    /* [annotation] */ 
;;                                                    _In_  SIZE_T BytecodeLength,
;;                                                    /* [annotation] */ 
;;                                                    _In_opt_  ID3D11ClassLinkage *pClassLinkage,
;;                                                    /* [annotation] */ 
;;                                                    _COM_Outptr_opt_  ID3D11ComputeShader **ppComputeShader);

;; HRESULT ( STDMETHODCALLTYPE *CreateClassLinkage )( 
;;                                                   ID3D11Device * This,
;;                                                   /* [annotation] */ 
;;                                                   _COM_Outptr_  ID3D11ClassLinkage **ppLinkage);

;; HRESULT ( STDMETHODCALLTYPE *CreateBlendState )( 
;;                                                 ID3D11Device * This,
;;                                                 /* [annotation] */ 
;;                                                 _In_  const D3D11_BLEND_DESC *pBlendStateDesc,
;;                                                 /* [annotation] */ 
;;                                                 _COM_Outptr_opt_  ID3D11BlendState **ppBlendState);

;; HRESULT ( STDMETHODCALLTYPE *CreateDepthStencilState )( 
;;                                                        ID3D11Device * This,
;;                                                        /* [annotation] */ 
;;                                                        _In_  const D3D11_DEPTH_STENCIL_DESC *pDepthStencilDesc,
;;                                                        /* [annotation] */ 
;;                                                        _COM_Outptr_opt_  ID3D11DepthStencilState **ppDepthStencilState);

;; HRESULT ( STDMETHODCALLTYPE *CreateRasterizerState )( 
;;                                                      ID3D11Device * This,
;;                                                      /* [annotation] */ 
;;                                                      _In_  const D3D11_RASTERIZER_DESC *pRasterizerDesc,
;;                                                      /* [annotation] */ 
;;                                                      _COM_Outptr_opt_  ID3D11RasterizerState **ppRasterizerState);

;; HRESULT ( STDMETHODCALLTYPE *CreateSamplerState )( 
;;                                                   ID3D11Device * This,
;;                                                   /* [annotation] */ 
;;                                                   _In_  const D3D11_SAMPLER_DESC *pSamplerDesc,
;;                                                   /* [annotation] */ 
;;                                                   _COM_Outptr_opt_  ID3D11SamplerState **ppSamplerState);

;; HRESULT ( STDMETHODCALLTYPE *CreateQuery )( 
;;                                            ID3D11Device * This,
;;                                            /* [annotation] */ 
;;                                            _In_  const D3D11_QUERY_DESC *pQueryDesc,
;;                                            /* [annotation] */ 
;;                                            _COM_Outptr_opt_  ID3D11Query **ppQuery);

;; HRESULT ( STDMETHODCALLTYPE *CreatePredicate )( 
;;                                                ID3D11Device * This,
;;                                                /* [annotation] */ 
;;                                                _In_  const D3D11_QUERY_DESC *pPredicateDesc,
;;                                                /* [annotation] */ 
;;                                                _COM_Outptr_opt_  ID3D11Predicate **ppPredicate);

;; HRESULT ( STDMETHODCALLTYPE *CreateCounter )( 
;;                                              ID3D11Device * This,
;;                                              /* [annotation] */ 
;;                                              _In_  const D3D11_COUNTER_DESC *pCounterDesc,
;;                                              /* [annotation] */ 
;;                                              _COM_Outptr_opt_  ID3D11Counter **ppCounter);

;; HRESULT ( STDMETHODCALLTYPE *CreateDeferredContext )( 
;;                                                      ID3D11Device * This,
;;                                                      UINT ContextFlags,
;;                                                      /* [annotation] */ 
;;                                                      _COM_Outptr_opt_  ID3D11DeviceContext **ppDeferredContext);

;; HRESULT ( STDMETHODCALLTYPE *OpenSharedResource )( 
;;                                                   ID3D11Device * This,
;;                                                   /* [annotation] */ 
;;                                                   _In_  HANDLE hResource,
;;                                                   /* [annotation] */ 
;;                                                   _In_  REFIID ReturnedInterface,
;;                                                   /* [annotation] */ 
;;                                                   _COM_Outptr_opt_  void **ppResource);

;; HRESULT ( STDMETHODCALLTYPE *CheckFormatSupport )( 
;;                                                   ID3D11Device * This,
;;                                                   /* [annotation] */ 
;;                                                   _In_  DXGI_FORMAT Format,
;;                                                   /* [annotation] */ 
;;                                                   _Out_  UINT *pFormatSupport);

;; HRESULT ( STDMETHODCALLTYPE *CheckMultisampleQualityLevels )( 
;;                                                              ID3D11Device * This,
;;                                                              /* [annotation] */ 
;;                                                              _In_  DXGI_FORMAT Format,
;;                                                              /* [annotation] */ 
;;                                                              _In_  UINT SampleCount,
;;                                                              /* [annotation] */ 
;;                                                              _Out_  UINT *pNumQualityLevels);

;; void ( STDMETHODCALLTYPE *CheckCounterInfo )( 
;;                                              ID3D11Device * This,
;;                                              /* [annotation] */ 
;;                                              _Out_  D3D11_COUNTER_INFO *pCounterInfo);

;; HRESULT ( STDMETHODCALLTYPE *CheckCounter )( 
;;                                             ID3D11Device * This,
;;                                             /* [annotation] */ 
;;                                             _In_  const D3D11_COUNTER_DESC *pDesc,
;;                                             /* [annotation] */ 
;;                                             _Out_  D3D11_COUNTER_TYPE *pType,
;;                                             /* [annotation] */ 
;;                                             _Out_  UINT *pActiveCounters,
;;                                             /* [annotation] */ 
;;                                             _Out_writes_opt_(*pNameLength)  LPSTR szName,
;;                                             /* [annotation] */ 
;;                                             _Inout_opt_  UINT *pNameLength,
;;                                             /* [annotation] */ 
;;                                             _Out_writes_opt_(*pUnitsLength)  LPSTR szUnits,
;;                                             /* [annotation] */ 
;;                                             _Inout_opt_  UINT *pUnitsLength,
;;                                             /* [annotation] */ 
;;                                             _Out_writes_opt_(*pDescriptionLength)  LPSTR szDescription,
;;                                             /* [annotation] */ 
;;                                             _Inout_opt_  UINT *pDescriptionLength);

;; HRESULT ( STDMETHODCALLTYPE *CheckFeatureSupport )( 
;;                                                    ID3D11Device * This,
;;                                                    D3D11_FEATURE Feature,
;;                                                    /* [annotation] */ 
;;                                                    _Out_writes_bytes_(FeatureSupportDataSize)  void *pFeatureSupportData,
;;                                                    UINT FeatureSupportDataSize);

;; HRESULT ( STDMETHODCALLTYPE *GetPrivateData )( 
;;                                               ID3D11Device * This,
;;                                               /* [annotation] */ 
;;                                               _In_  REFGUID guid,
;;                                               /* [annotation] */ 
;;                                               _Inout_  UINT *pDataSize,
;;                                               /* [annotation] */ 
;;                                               _Out_writes_bytes_opt_(*pDataSize)  void *pData);

;; HRESULT ( STDMETHODCALLTYPE *SetPrivateData )( 
;;                                               ID3D11Device * This,
;;                                               /* [annotation] */ 
;;                                               _In_  REFGUID guid,
;;                                               /* [annotation] */ 
;;                                               _In_  UINT DataSize,
;;                                               /* [annotation] */ 
;;                                               _In_reads_bytes_opt_(DataSize)  const void *pData);

;; HRESULT ( STDMETHODCALLTYPE *SetPrivateDataInterface )( 
;;                                                        ID3D11Device * This,
;;                                                        /* [annotation] */ 
;;                                                        _In_  REFGUID guid,
;;                                                        /* [annotation] */ 
;;                                                        _In_opt_  const IUnknown *pData);

;; D3D_FEATURE_LEVEL ( STDMETHODCALLTYPE *GetFeatureLevel )( 
;;                                                          ID3D11Device * This);

;; UINT ( STDMETHODCALLTYPE *GetCreationFlags )( 
;;                                              ID3D11Device * This);

;; HRESULT ( STDMETHODCALLTYPE *GetDeviceRemovedReason )( 
;;                                                       ID3D11Device * This);

;; void ( STDMETHODCALLTYPE *GetImmediateContext )( 
;;                                                 ID3D11Device * This,
;;                                                 /* [annotation] */ 
;;                                                 _Outptr_  ID3D11DeviceContext **ppImmediateContext);

;; HRESULT ( STDMETHODCALLTYPE *SetExceptionMode )( 
;;                                                 ID3D11Device * This,
;;                                                 UINT RaiseFlags);

;; UINT ( STDMETHODCALLTYPE *GetExceptionMode )( 
;;                                              ID3D11Device * This);

;; END_INTERFACE
;; } ID3D11DeviceVtbl;


(com-on::define-comstruct dxgi-device
  (set-private-data com-on::hresult (name :pointer) (data-size :uint) (data :pointer))
  (set-private-data-interface com-on::hresult (name :pointer) (unknown :pointer))
  (private-data com-on::hresult (name :pointer) (data-size :pointer) (data :pointer))
  (parent com-on::hresult (riid :pointer) (parent :pointer))
  (adapter com-on::hresult (adapter :pointer))
  (create-surface com-on::hresult (desc :pointer) (shared-resource :pointer) (surface :pointer))
  (query-resource-residency com-on::hresult (resources :pointer) (residency-status :pointer))
  (set-gpu-thread-priority com-on::hresult (priority :int))
  (gpu-thread-priority com-on::hresult (priority :pointer)))
