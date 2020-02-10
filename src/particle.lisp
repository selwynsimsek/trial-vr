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

(trial:define-asset (workbench water-jet-particles) trial::vertex-struct-buffer
    'trial::simple-particle :struct-count 1024)

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
  (alexandria:when-let ((matrix (pose (trial:handler trial:*context*))))
    (let ((factor -0.01))
      (setf (trial::location particle) (trial::vec3
                                        (aref matrix 12) (aref matrix 13) (aref matrix 14)))
      (setf (trial::velocity particle) (3d-vectors:v+ (trial::vec3
                                                       (* factor (aref matrix 8))
                                                       (* factor (aref matrix 9))
                                                       (* factor (aref matrix 10)))
                                                      (trial::vec3 #1= (* 0.001 (1- (* 2 (random 1.0)))) #1# #1#))))))

(defmethod trial::update-particle-state :before ((water-jet water-jet) tick particle output)
  (let ((vel (trial::velocity particle)))
    (decf (trial::vy3 vel) 0.0003)
    (setf (trial::velocity output) vel)))

(defmethod trial::new-particle-count ((water-jet water-jet) tick)
  (if (vr::state-p (button (trial:handler trial:*context*))) 10 0))

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
