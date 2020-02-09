;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Defines a basic particle system for show in trial-vr.

(in-package :trial-vr)

(trial:define-asset (workbench particles) trial::vertex-struct-buffer
    'trial::simple-particle :struct-count 1024)

(trial:define-shader-subject fireworks (trial::simple-particle-emitter)
  ()
  (:default-initargs :particle-mesh (change-class (trial:make-sphere 1) 'trial:vertex-array
                                                  :vertex-attributes '(trial:location))
                     :particle-buffer (trial:asset 'workbench 'particles)))

(defmethod trial::initial-particle-state ((fireworks fireworks) tick particle)
  (let ((dir (trial::polar->cartesian (trial::vec2 (/ (sxhash (trial::fc tick)) (ash 2 60)) (mod (sxhash (trial::fc tick)) 100)))))
    (setf (trial::velocity particle) (trial::vec (trial::vx dir) (+ 2.5 (mod (sxhash (trial::fc tick)) 2)) (trial::vy dir))))
  (setf (trial::lifetime particle) (trial::vec 0 (+ 3.0 (random 1.0)))))

(defmethod trial::update-particle-state :before ((fireworks fireworks) tick particle output)
  (let ((vel (trial::velocity particle)))
    (decf (trial::vy3 vel) 0.005)
    (when (< (abs (- (trial::vx (trial::lifetime particle)) 2.5)) 0.05)
      (let ((dir (trial::polar->cartesian
                  (trial::vec3 (+ 1.5 (random 0.125)) (random (* 2 PI)) (random (* 2 PI))))))
        (trial::vsetf vel (trial::vx dir) (trial::vy dir) (trial::vz dir))))
    (setf (trial::velocity output) vel)))

(defmethod trial::new-particle-count ((fireworks fireworks) tick)
  (if (= 0 (mod (trial::fc tick) (* 10 1)))
      128 0))

(trial:define-class-shader (fireworks :vertex-shader 1)
  "layout (location = 1) in vec2 in_lifetime;
layout (location = 2) in vec3 location;

out vec2 lifetime;

void main(){
  lifetime = in_lifetime;
}")

(trial:define-class-shader (fireworks :fragment-shader)
  "out vec4 color;

in vec2 lifetime;

void main(){
  if(lifetime.x <= 2.5)
    color = vec4(1);
  else{
    float lt = lifetime.y-lifetime.x;
    color = vec4(lt*2, lt, 0, 1);
  }
}")
