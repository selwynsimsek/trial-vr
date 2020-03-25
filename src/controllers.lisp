;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Load render models (controller, HMD etc.) for display in VR.

(in-package #:org.shirakumo.trial.vr)

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

(trial:define-shader-subject controller-body
    (trial:vertex-entity trial:textured-entity)
  ((handedness :initarg :handedness :accessor handedness))
  (:default-initargs :texture (trial:asset 'workbench 'controller-body-diffuse)
                     :vertex-array (trial:asset 'workbench 'controller-body-mesh)))

(defmethod trial:paint :around ((obj controller-body) target)
  (let ((pose (controller-pose-for-handedness (handedness obj))))
    (when (and pose (eq :running-ok (vr::tracking-result pose)))
      (let ((trial:*model-matrix*
              (3d-matrices:m* trial:*model-matrix*
                              (3d-matrices:mtranspose (sb->3d
                                                       (vr::device-to-absolute-tracking pose))))))
        (call-next-method)))))

