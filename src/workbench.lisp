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
    (trial:enter (make-instance 'trial::skybox :texture (trial:asset 'workbench 'trial::skybox))
                 scene)
    (trial:enter (make-instance 'cube) scene)
    (trial:enter (make-instance 'actor) scene)
    (trial:enter (make-instance 'controller-body :handedness :left) scene)
    (trial:enter (make-instance 'controller-body :handedness :right) scene)
    (trial:enter (make-instance 'water-jet) scene)
  (trial:maybe-reload-scene)))

