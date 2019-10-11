;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; The trial workbench for VR experimentation

(in-package :trial-vr)

(defclass workbench (trial:main) ()
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
    (trial:enter (make-instance 'trial::skybox
                                :texture (trial:asset 'workbench 'trial::skybox))
                 scene)
    (trial:enter (make-instance 'cube) scene)
    (trial:enter (setf *head* (make-instance 'head)) scene)
    (trial:enter (setf *left-render-pass* (make-instance 'left-eye-render-pass)) scene)
    (trial:enter (setf *right-render-pass* (make-instance 'right-eye-render-pass)) scene)
    (trial:enter (setf *compositor-render-pass* (make-instance 'compositor-render-pass)) scene)
    (trial:connect (trial:port *left-render-pass* 'trial:color)
                   (trial:port *compositor-render-pass* 'left-pass-color)
                   scene)
    (trial:connect (trial:port *right-render-pass* 'trial:color)
                   (trial:port *compositor-render-pass* 'right-pass-color)
                   scene)
    (trial:connect (trial:port *left-render-pass* 'trial:depth)
                   (trial:port *compositor-render-pass* 'left-pass-depth)
                   scene)
    (trial:connect (trial:port *right-render-pass* 'trial:depth)
                   (trial:port *compositor-render-pass* 'right-pass-depth)
                   scene)
    ;(trial:enter (make-instance 'trial:render-pass) scene)
    )
  (trial:maybe-reload-scene))
