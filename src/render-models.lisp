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

(defmethod trial:paint :around ((obj posed-entity) target)

      (call-next-method))  ; do this better!

(defclass controller-container (trial::array-container)
  ((parity :accessor parity :initarg :parity :initform :left)
   (action :accessor action :initarg :action :initform (error "need an action"))))

(defun parity->action (parity)
  (if (eq parity :left)
      (find-action "/actions/trial_vr/in/Hand_Left"
                   (trial:handler trial:*context*))
      (find-action "/actions/trial_vr/in/Hand_Right"
                   (trial:handler trial:*context*))))

(defun controller-container (parity)
  (make-instance 'controller-container :parity parity
                                       :action (parity->action parity)))

(defmethod trial:paint :around ((obj controller-container) target)
  (with-slots (parity action) obj
    (unless action (setf action (parity->action parity)))
    (when (and action (vr::action-data action) (slot-boundp (vr::action-data action) 'vr::active-p))
      (let ((pose (vr::device-to-absolute-tracking (vr::pose (vr::action-data action)))))
        (let ((trial:*model-matrix* (3d-matrices:m* trial:*model-matrix*
                                                    (3d-matrices:mtranspose (sb->3d pose)))))
          (dummy (call-next-method)))))))
