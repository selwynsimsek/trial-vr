;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Defines a basic particle system for show in trial-vr.

(in-package #:org.shirakumo.fraf.trial.vr)

(defvar *running-water* (asdf:system-relative-pathname :trial-vr #p"assets/sounds/running-water.wav"))
; no.
(defvar *last-controller-location* nil)
(defvar *fired-p*)

(defun fire-gun ()
  (setf *fired-p* t
        *last-controller-location* (controller-pose-for-handedness :right))
  (trial:enter (make-instance 'jab) (trial:scene (trial:handler trial:*context*))))

;; (trial:define-asset (trial-assets:workbench jab-particles) trial::vertex-struct-buffer
;;     'trial::simple-particle :struct-count 102400)

(trial:define-shader-entity jab (trial::simple-particle-emitter)
  ()
  (:default-initargs :particle-mesh (change-class (trial:make-sphere 0.003) 'trial:vertex-array
                                                  :vertex-attributes '(trial:location))
                     :particle-buffer (trial:asset 'trial-assets:workbench 'jab-particles)))

(defmethod trial::initial-particle-state ((jab jab) tick particle)
  (alexandria:when-let ((pose (controller-pose-for-handedness :right)))
    (alexandria:when-let ((matrix (vr::device-to-absolute-tracking pose)))
      (let ((controller-origin (trial::vec3 (aref matrix 12) (aref matrix 13) (aref matrix 14)))
            (controller-direction
              (trial::v* -0.1 (trial::vec3  (aref matrix 8) (aref matrix 9) (aref matrix 10)))))
        (setf (trial::location particle) controller-origin
              (trial::velocity particle) controller-direction
              (trial::lifetime particle) (trial::vec2 0 (+ 3 (random 2.0))))))))

(defmethod trial::update-particle-state :before ((jab jab) tick particle output)
  (let ((vel (trial::velocity particle)))
    (setf (trial::velocity output) vel)
    (when (< (abs (- (trial::vx (trial::lifetime particle)) 1)) 0.05)
      (trial::setf (trial::velocity output)
                   (trial::v* 0.8
                              (trial::vc (trial::velocity output)
                                         (trial::v- 1.0 (trial::vec3 (random 2.0) (random 2.0) (random 2.0)))))))))

(let (trigger-already-pressed-p)
  (defmethod trial::new-particle-count ((jab jab) tick)
    (when (and (trigger-active-p) (not trigger-already-pressed-p))
      (setf trigger-already-pressed-p t)
      (return-from trial::new-particle-count 1000))
    (unless (trigger-active-p) (setf trigger-already-pressed-p nil))
    0))

(trial:define-class-shader (jab :vertex-shader 1)
  "layout (location = 1) in vec2 in_lifetime;
layout (location = 2) in vec3 location;

out vec2 lifetime;

void main(){
  lifetime = in_lifetime;
}")

(trial:define-class-shader (jab :fragment-shader)
  "out vec4 color;

in vec2 lifetime;
float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}
void main(){
if(lifetime.x <= lifetime.y-2.0){
  color=vec4(1);
}
else{
float lt = (lifetime.y-lifetime.x)/(lifetime.y-2.0);
color=vec4(0.5*lt,1.0-0.5*lt*lt,0.5*lt,lt);
}
}")



;; (trial:define-asset (trial-assets:workbench fireworks-particles) trial::vertex-struct-buffer
;;     'trial::simple-particle
;;   :struct-count 1024)

(trial:define-shader-entity fireworks (trial::simple-particle-emitter)
  ()
  (:default-initargs :particle-mesh (change-class (trial:make-sphere 1) 'trial:vertex-array :vertex-attributes '(trial:location))
                     :particle-buffer (trial:asset 'trial-assets:workbench 'fireworks-particles)))

(defmethod trial::initial-particle-state ((fireworks fireworks) tick particle)
  (let ((dir (trial::polar->cartesian (trial::vec2 (/ (sxhash (trial::fc tick)) (ash 2 60)) (mod (sxhash (trial::fc tick)) 100)))))
    (setf (trial::velocity particle) (trial::vec (trial::vx dir) (+ 2.5 (mod (sxhash (trial::fc tick)) 2)) (trial::vy dir))))
  (setf (trial::lifetime particle) (trial::vec 0 (+ 3.0 (random 1.0))))
  (setf (trial::location particle) (trial::vec 100.0 0.0 -10.0)))

(defmethod trial::update-particle-state :before ((fireworks fireworks) tick particle output)
  (let ((vel (trial::velocity particle)))
    (decf (trial::vy3 vel) 0.005)
    (when (< (abs (- (trial::vx (trial::lifetime particle)) 2.5)) 0.05)
      (let ((dir (trial::polar->cartesian (trial::vec3 (+ 1.5 (random 0.125)) (random (* 2 PI)) (random (* 2 PI))))))
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
