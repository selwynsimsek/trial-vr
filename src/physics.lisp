;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Physics in Trial using cl-ode.

(in-package #:org.shirakumo.fraf.trial.vr)

(defclass ode-physics-handler ()
  ((world :initarg :world :initform nil :accessor world)
   (physics-space :initarg :physics-space :initform nil :accessor physics-space)))
#-win32
(defmethod trial:start :after ((handler ode-physics-handler))
  (with-slots (world physics-space) handler
    (ode:init)
    (setf world (ode:world-create))
    (ode::world-set-defaults world)
    (ode::world-set-gravity world 0 -10 0)
    (setf physics-space (ode::hash-space-create nil))))
#-win32
(defmethod trial:stop :after ((handler ode-physics-handler))
  (with-slots (world physics-space) handler
    (ode:world-destroy world)))

;; (trial:define-handler (head trial:tick) (ev)
;;   (ode:world-step (world workbench) (trial::dt ev)))


