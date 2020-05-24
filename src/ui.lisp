;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Contains routines and definitions to facilitate the use of Alloy as a UI in trial-vr.

(in-package #:org.shirakumo.fraf.trial.vr)

(defclass dui (trial-alloy:ui
               alloy:smooth-scaling-ui
               simple-presentations::default-look-and-feel)
  ())

(trial:define-shader-pass ui-render-pass (trial:render-pass)
  ((trial:color :port-type trial:output :attachment :color-attachment0
                :texspec (:target :texture-2d :width 640 :height 480))
   (overlays :initarg :overlays :initform #() :accessor overlays)
   (debug-overlay :initform (make-instance 'vr:overlay) :accessor debug-overlay)
   (dui :initarg :dui :initform nil :accessor dui))
  (:default-initargs :name :ui-render-pass))

(defmethod initialize-instance :after ((instance ui-render-pass) &key)
  (vr:show (debug-overlay instance)))

(defmethod trial:paint :after
    ((subject trial:pipelined-scene) (pass ui-render-pass))
  (let ((texture-id (trial:data-pointer (trial:texture (flow:port pass 'trial:color))))
        (overlays (overlays pass)))
    (map nil (lambda (overlay) (setf (vr:texture overlay) texture-id)) overlays)
    (setf (vr:texture (debug-overlay pass)) texture-id)
    (setf (vr:transform (debug-overlay pass) :absolute)
          #(0.0 0.0 1.0 -1.0
            0.0 1.0 0.0 1.0
            -1.0 0.0 0.0 0.0))))

(defmethod trial:paint-with :around ((pass ui-render-pass) (thing trial:shader-entity))
  (declare (ignore pass thing)))

(defmethod trial:paint-with :around ((pass ui-render-pass) (thing dui))
  (when (eq (dui pass) thing)
    (call-next-method)))

(defun set-overlay-visibility (visible-p key)
  (if visible-p
      (vr:show-overlay (vr:find-overlay key))
      (vr:hide-overlay (vr:find-overlay key))))

(defun set-overlay-displacement (key x y z)
  (vr:set-overlay-transform-absolute
   (vr:find-overlay key) :standing (vector 1.0 0.0 0.0 x
                                           0.0 1.0 0.0 y
                                           0.0 0.0 1.0 z)))
