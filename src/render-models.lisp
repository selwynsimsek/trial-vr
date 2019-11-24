;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Load render models (controller, HMD etc.) for display in VR.


(in-package :trial-vr)

(defvar *controller-body*
  (asdf:system-relative-pathname :trial-vr #p"assets/vr_controller_vive_1_5/controller.obj"))

(trial:define-asset (workbench controller-body-mesh) trial::mesh
    (gethash "<dummy_root>" (trial:meshes (trial:read-geometry *controller-body* :wavefront))))

(trial:define-asset (workbench controller-body-diffuse) trial::image
    (asdf:system-relative-pathname :trial-vr #p"assets/vr_controller_vive_1_5/onepointfive_texture.png"))

(trial:define-shader-subject controller-body (trial:vertex-entity trial:textured-entity trial:located-entity
                                                                  trial:rotated-entity)
  ()
  (:default-initargs :texture (trial:asset 'workbench 'controller-body-diffuse)
                     :vertex-array (trial:asset 'workbench 'controller-body-mesh)))

(let ((action)
      (active-action-sets))
  (trial:define-handler (controller-body trial:tick) (trial::ev)
    (unless action
      (setf action (vr::action "/actions/demo/in/Hand_Right")))
    (unless active-action-sets
      (setf active-action-sets
            (vector (make-instance 'vr::active-action-set
                                   :action-set-handle (vr::action-set "/actions/demo")
                                   :restricted-to-device 0
                                   :secondary-action-set 0
                                   :padding 0
                                   :priority 0))))
    (vr::update-action-state active-action-sets)
    (handler-case
        (let ((matrix (vr::device-to-absolute-tracking
                       (vr::pose
                        (vr::pose-action-data-relative-to-now action :standing 0.0)))))
          (setf (trial:location controller-body)
                (trial::vec3 (aref matrix 12) (aref matrix 13) (aref matrix 14)))
          ;; (setf (trial:rotation controller-body)
          ;;       (trial::mat3 (vector (aref matrix 0) (aref matrix 1) (aref matrix 2)
          ;;                            (aref matrix 4) (aref matrix 5) (aref matrix 6)
          ;;                            (aref matrix 8) (aref matrix 9) (aref matrix 10))))
          )

      (t () (format t "error")))
    ;(setf (trial::location controller-body ))
    ))

(trial:maybe-reload-scene)
