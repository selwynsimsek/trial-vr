;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Defines a basic particle system for show in trial-vr.

(in-package #:org.shirakumo.fraf.trial.vr)

(defvar *running-water* (asdf:system-relative-pathname :trial-vr #p"assets/sounds/running-water.wav"))

(trial:define-asset (workbench water-jet-particles) trial::vertex-struct-buffer
    'trial::simple-particle :struct-count 1024)

()

(trial:define-shader-subject water-jet (trial::simple-particle-emitter)
  ()
  (:default-initargs :particle-mesh (change-class (trial:make-sphere 0.003) 'trial:vertex-array
                                                  :vertex-attributes '(trial:location))
                     :particle-buffer (trial:asset 'workbench 'water-jet-particles)))

(defmethod trial::initial-particle-state ((water-jet water-jet) tick particle)
  (let ((dir (trial::polar->cartesian (trial::vec2 (/ (sxhash (trial::fc tick)) (ash 2 60)) (mod (sxhash (trial::fc tick)) 100)))))
    (let ((factor 0.01))
      (setf (trial::velocity particle) (trial::vec (* factor (trial::vx dir)) (* factor (+ 2.5 (mod (sxhash (trial::fc tick)) 2))) (* factor (trial::vy dir))))))
  (setf (trial::lifetime particle) (trial::vec 0 (* 0.3 (+ 3.0 (random 1.0)))))
  (alexandria:when-let ((matrix (controller-pose)))
    (let ((factor -0.01))
      (setf (trial::location particle) (trial::vec3
                                        (aref matrix 12) (aref matrix 13) (aref matrix 14)))
      (setf (trial::velocity particle)
            (3d-vectors:v+ (trial::vec3
                            (* factor (aref matrix 8)) ; aligned with principal axis of controller
                            (* factor (aref matrix 9))
                            (* factor (aref matrix 10)))
                           (trial::vec3 #1= (* 0.001 (1- (* 2 (random 1.0)))) #1# #1#))))))

(defmethod trial::update-particle-state :before ((water-jet water-jet) tick particle output)
  (let ((vel (trial::velocity particle)))
    (decf (trial::vy3 vel) 0.0003)
    (setf (trial::velocity output) vel)))

(defmethod trial::new-particle-count ((water-jet water-jet) tick)
  10)

(trial:define-class-shader (water-jet :vertex-shader 1)
  "layout (location = 1) in vec2 in_lifetime;
layout (location = 2) in vec3 location;

out vec2 lifetime;

void main(){
  lifetime = in_lifetime;
}")

(trial:define-class-shader (water-jet :fragment-shader)
  "out vec4 color;

in vec2 lifetime;

void main(){
    color=vec4(0,0,1,1);
}")
