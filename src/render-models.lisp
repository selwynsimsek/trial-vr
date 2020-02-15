;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Load render models (controller, HMD etc.) for display in VR.

(in-package :trial-vr)

(trial:define-asset (workbench controller-body-mesh) trial::mesh
  (gethash
   "controller.obj"
   (trial:meshes
    (trial:read-geometry
     (asdf:system-relative-pathname :trial-vr #p"assets/vr_controller_vive_1_5/controller.obj")
     :wavefront))))

(trial:define-asset (workbench controller-body-diffuse) trial::image
    (asdf:system-relative-pathname
     :trial-vr #p"assets/vr_controller_vive_1_5/onepointfive_texture.png"))

(defclass posed-entity ()
  ((pose :initarg :pose :initform (3d-matrices:meye 4) :accessor pose)))

(trial:define-shader-subject controller-body
    (trial:vertex-entity trial:textured-entity posed-entity)
  ()
  (:default-initargs :texture (trial:asset 'workbench 'controller-body-diffuse)
                     :vertex-array (trial:asset 'workbench 'controller-body-mesh)))

(trial:define-handler (controller-body trial:tick) (trial::ev)
  (alexandria:when-let ((matrix (pose (trial:handler trial:*context*))))
    (setf (pose controller-body) matrix)))

(defmethod trial:paint :around ((obj posed-entity) target)
  (if (pose obj)
      (let ((trial:*model-matrix* (3d-matrices:m* trial:*model-matrix* (3d-matrices:mtranspose (sb->3d (pose obj))))))
        (call-next-method))
      (call-next-method)))  ; do this better!
