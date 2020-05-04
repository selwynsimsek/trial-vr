;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; A cube which has emacs on the side.

(in-package #:org.shirakumo.fraf.trial.vr)

(defparameter *emacs-width* 1024)
(defparameter *emacs-height* 1024)

#-win32
(defun emacs-cube-texture ()
  "Returns a pointer to raw bitmap data representing an Emacs window."
  (cl-xwd:shared-memory-raw-pointer
   (parse-integer
    (alexandria:read-file-into-string
     (merge-pathnames #p"vrx-utils/shared-memory-id" (user-homedir-pathname))))))

(trial:define-asset (workbench cube) trial:mesh
    (trial:make-cube 1.3))

(trial:define-shader-subject cube (trial:vertex-entity trial:colored-entity trial:textured-entity
                                                       trial:located-entity trial:rotated-entity
                                                       trial:selectable)
  ((vel :initform 0
        :accessor vel))
  (:default-initargs :vertex-array (trial:asset 'workbench 'cube)
                     :texture  (make-instance 'trial:texture
                                           ;  :width 1920
                                             ;:height 1080
                                             :data-pointer org.shirakumo.fraf.trial.vr.windows::*gl-texture-int*
                                             #-win32 :pixel-data #-win32 (emacs-cube-texture)
                                            ; :pixel-type :unsigned-short-5-6-5
                                            ; :internal-format :rgb
                                            ; :levels 0
                                             )
                     :name :cube
                     :rotation (trial::vec (/ PI -2) 0 0)
                     :color (trial::vec3-random 0.2 0.8)
                     :location (trial::vec3 0 1 -1.55)))
#-win32
(trial:define-handler (cube trial:tick) (trial::ev)
  (when (trial:allocated-p (trial:texture cube)) (trial:deallocate (trial:texture cube)))
  (trial:allocate (trial:texture cube)))

