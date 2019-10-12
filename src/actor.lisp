;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Defines a virtual reality actor which can be entered into a trial scene.

(in-package :trial-vr)

(defclass actor ()
  ((head :initarg :head)
   (compositor-render-pass :initarg :compositor-render-pass)))

(defmethod trial:enter ((unit actor) scene)
  (let* ((head (make-instance 'head))
         (left-render-pass (make-instance 'left-eye-render-pass :head head))
         (right-render-pass (make-instance 'right-eye-render-pass :head head))
         (compositor-render-pass (make-instance 'compositor-render-pass)))
    (trial:enter head scene)
    (trial:enter left-render-pass scene)
    (trial:enter right-render-pass scene)
    (trial:enter compositor-render-pass scene)
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
                   scene)
    (setf (slot-value unit 'head) head
          (slot-value unit 'compositor-render-pass) compositor-render-pass)))
