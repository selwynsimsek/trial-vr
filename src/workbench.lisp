;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; The trial workbench for VR experimentation

(in-package #:org.shirakumo.fraf.trial.vr)

(defclass workbench (trial:main vr-input-handler ode-physics-handler) ()
  (:default-initargs :clear-color (trial::vec 0.3 0.3 0.3 0)))

;(trial:define-pool workbench :base 'trial:trial)

(trial:define-asset (trial-assets::workbench trial::skybox) trial::image
    '(#p"heart-in-the-sand/posx.jpg"
      #p"heart-in-the-sand/negx.jpg"
      #p"heart-in-the-sand/posy.jpg"
      #p"heart-in-the-sand/negy.jpg"
      #p"heart-in-the-sand/posz.jpg"
      #p"heart-in-the-sand/negz.jpg")
  :target :texture-cube-map)

(progn
  (defmethod trial:setup-scene ((workbench workbench) scene)
    (v:info :trial.vr "in trial:setup-scene")
    ;
    (trial:enter
     (make-instance 'trial::skybox :texture (trial:// 'trial-assets::workbench  'trial::skybox)) scene)
    (trial:enter (make-instance 'cube) scene)
    (trial:enter (make-instance 'actor) scene)
    (trial:stage workbench (make-instance 'trial:staging-area))
    (trial:enter (make-instance 'controller-body :handedness :left) scene)
    (trial:enter (make-instance 'controller-body :handedness :right) scene)
    ;(trial:enter (make-instance 'helicopter-seats) scene)
                                       ; (trial:enter (make-instance 'jab) scene)
                                        ; (trial:enter (make-instance 'fireworks) scene)
    )
  (trial:maybe-reload-scene))

(defmethod trial:stage :after ((workbench workbench) (area trial:staging-area))
;  (trial:stage (trial:// 'trial-assets::workbench 'cube-mesh) area)
 ; (trial:stage (trial:// 'trial-assets::workbench 'controller-body-diffuse) area)
 ; (trial:stage (trial:// 'trial-assets::workbench 'helicopter-mesh-35) area)
  
 ; (trial:stage (trial:// 'trial-assets::workbench 'helicopter-seats-diffuse) area)
  (v:info :trial.vr "in trial:stage"))

