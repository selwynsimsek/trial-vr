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
   (overlay-key :initarg :overlay-key :initform (error "Need to have an overlay name!")
                :accessor overlay-key)
   (overlay-friendly-name :initarg :overlay-friendly-name :initform nil
                          :accessor overlay-friendly-name)
   (dui :initarg :dui :initform nil :accessor dui)))

(trial:define-shader-pass ui-compositor-render-pass (trial:render-pass)
  ((ui-pass-1 :port-type trial:input)
   (ui-pass-2 :port-type trial:input)))

(defmethod initialize-instance :after ((instance ui-render-pass) &key)
  (unless (overlay-friendly-name instance)
    (setf (overlay-friendly-name instance)
          (format nil "TrialVR overlay <~a>" (overlay-key instance))))
  (vr:create-overlay (overlay-key instance) (overlay-friendly-name instance)))
  
(defmethod trial:paint :before ((subject trial:pipelined-scene) (pass ui-render-pass))
  (trial:project-view (make-instance 'trial:2d-camera) nil)) ; does this work?

(defmethod trial:paint :after ((subject trial:pipelined-scene) (pass ui-render-pass))
  (let ((texture-id (trial:data-pointer (trial:texture (flow:port pass 'trial:color))))
        (overlay-key (vr:find-overlay (overlay-key pass))))
    (vr:set-overlay-texture overlay-key texture-id)
    (dummy texture-id)))

;; (defmethod trial:paint-with ((pass ui-render-pass) thing)
;;   (when (or (typep thing 'trial:pipelined-scene)
;;             (typep thing 'dui))
;;     (call-next-method)))

;; (defmethod trial:paint-with ((pass eye-render-pass) thing)
;;   (unless (typep thing 'dui) (call-next-method)))

(defmethod trial:paint-with :around ((pass eye-render-pass) (thing dui))
  (declare (ignore pass thing)))

(defmethod trial:paint-with :around ((pass ui-render-pass) (thing trial:shader-entity))
  (declare (ignore pass thing)))

(defmethod trial:paint-with :around ((pass ui-render-pass) (thing dui))
  (when (eq (dui pass) thing)
    (call-next-method)))

;; (defmethod trial:paint-with :around ((pass ui-render-pass) (thing trial:pipelined-scene))
;;   (call-next-method))

(defun set-overlay-visibility (visible-p key)
  (if visible-p
      (vr:show-overlay (vr:find-overlay key))
      (vr:hide-overlay (vr:find-overlay key))))
