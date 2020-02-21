;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; The trial workbench for VR experimentation

(in-package :trial-vr)

(defclass workbench (trial:main vr-input-handler ode-physics-handler) ()
  (:default-initargs :clear-color (trial::vec 0.3 0.3 0.3 0)))

(trial:define-pool workbench
  :base 'trial:trial)

(trial:define-asset (workbench trial::skybox) trial::image
    '(#p"nissi-beach/posx.jpg"
      #p"nissi-beach/negx.jpg"
      #p"nissi-beach/posy.jpg"
      #p"nissi-beach/negy.jpg"
      #p"nissi-beach/posz.jpg"
      #p"nissi-beach/negz.jpg")
  :target :texture-cube-map)

(progn
  (defmethod trial:setup-scene ((workbench workbench) scene)
    (let ((left-controller (controller-container :left))
          (right-controller (controller-container :right))
          (left-body (make-instance 'controller-body))
          (right-body (make-instance 'controller-body))
          (left-jet (make-instance 'water-jet))
          (right-jet (make-instance 'water-jet)))
      (trial:enter (make-instance 'trial::skybox :texture (trial:asset 'workbench 'trial::skybox))
                   scene)
      (trial:enter (make-instance 'cube) scene)
      (trial:enter (make-instance 'actor) scene)
      ;(trial:enter left-jet left-controller)
      (trial:enter left-body left-controller)
      ;(trial:enter right-jet right-controller)
      (trial:enter right-body right-controller)
      (trial:register left-body scene)
      ;(trial:register left-jet scene)
      (trial:register right-body scene)
      ;(trial:register right-jet scene)
      (trial:enter left-controller scene)
      (trial:enter right-controller scene)))
  (trial:maybe-reload-scene))
