;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Defines a virtual reality actor which can be entered into a trial scene.

(in-package #:org.shirakumo.trial.vr)

(defclass actor ()
  ((name :initarg :actor)))

(defclass dui (trial-alloy:ui
               alloy:smooth-scaling-ui
               org.shirakumo.alloy.renderers.simple.presentations::default-look-and-feel)
  ())


(defmethod trial:enter ((unit actor) scene)
  (let* ((head (make-instance 'head))
         (left-render-pass (make-instance 'left-eye-render-pass))
         (right-render-pass (make-instance 'right-eye-render-pass))
         (compositor-render-pass (make-instance 'compositor-render-pass))
         (ui-render-pass (make-instance 'ui-render-pass))
         (ui (make-instance 'dui :target-resolution (alloy:px-size 800 600)))
         (focus (make-instance 'alloy:focus-list :focus-parent (alloy:focus-tree ui)))
         (layout (make-instance 'alloy:vertical-linear-layout
                                :layout-parent (alloy:layout-tree ui))))
    (let* ((data (3d-vectors:vec2 0 1))
           (vec (alloy:represent data 'trial-alloy::vec2
                                               :focus-parent focus :layout-parent layout)))
      (alloy:on (setf alloy:value) (value vec)
        (print value)))
    (trial:enter head scene)
    (trial:enter left-render-pass scene)
    (trial:enter right-render-pass scene)
    (trial:enter compositor-render-pass scene)
    (trial:enter ui-render-pass scene)
    (trial:enter ui scene)
    (trial:connect (trial:port left-render-pass 'trial:color)
                   (trial:port compositor-render-pass 'left-pass-color)
                   scene)
    (trial:connect (trial:port right-render-pass 'trial:color)
                   (trial:port compositor-render-pass 'right-pass-color)
                   scene)
    (trial:connect (trial:port left-render-pass 'trial:depth)
                   (trial:port compositor-render-pass 'left-pass-depth)
                   scene)
    (trial:connect (trial:port right-render-pass 'trial:depth)
                   (trial:port compositor-render-pass 'right-pass-depth)
                   scene)))
