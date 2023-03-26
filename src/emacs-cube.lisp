;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; A cube which has emacs on the side.

(in-package #:org.shirakumo.fraf.trial.vr)

(defparameter *emacs-width* 1024)
(defparameter *emacs-height* 1024)
(trial:define-pool trial-assets::workbench)

(trial:define-asset (trial-assets::workbench cube-mesh) trial:mesh    (trial:make-cube-mesh 3))

(trial:define-shader-entity cube (trial:vertex-entity trial:colored-entity trial:textured-entity
                                                       trial:located-entity trial:rotated-entity
                                                       trial:selectable)
  ((vel :initform 0
        :accessor vel))
  (:default-initargs :vertex-array  (trial:// 'trial-assets::workbench 'cube-mesh)
                     :texture  (make-instance 'trial:texture
                                              :width #+windows 1920 #+linux *emacs-width*
                                              :height #+windows 1080 #+linux *emacs-height*
                                              #+linux :pixel-data #+linux (emacs-cube-texture)
                                              #+windows :data-pointer
                                              (org.shirakumo.fraf.trial.vr.windows::gl-texture-name)
                                              :pixel-type :unsigned-short-5-6-5
                                              :internal-format :rgb
                                              :levels 0)
                     :name :cube
                     :rotation (trial::qfrom-angle trial::+vx+ (/ PI -2))
                     :color (trial::vec3-random 0.2 0.8)
                     :location (trial::vec3 0.0 3.0 0.0)))

#+linux
(defun emacs-cube-texture ()
  "Returns a pointer to raw bitmap data representing an Emacs window."
  (cl-xwd:shared-memory-raw-pointer
   (parse-integer
    (alexandria:read-file-into-string
     (merge-pathnames #p"vrx-utils/shared-memory-id" (user-homedir-pathname))))))

#+linux
(trial:define-handler (cube trial:tick) (trial::ev)
  (when (trial:allocated-p (trial:texture cube)) (trial:deallocate (trial:texture cube)))
  (trial:allocate (trial:texture cube)))
