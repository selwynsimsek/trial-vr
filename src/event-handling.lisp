;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Hooks controller input into the trial event handling system.

(in-package :trial-vr)

(defclass vr-input-handler ()
  ((action-set :initarg :action-set :initform nil :accessor action-set)
   (pose-action :initarg :pose-action :initform nil :accessor pose-action)
   (button-action :initarg :button-action :initform nil :accessor button-action)
   (pose :initarg :pose :initform nil :accessor pose)
   (button :initarg :button :initform nil :accessor button)))

(defvar *action-manifest-path* "/home/selwyn/openvr/samples/bin/hellovr_actions.json")

(defmethod trial:start :after ((handler vr-input-handler))
  (vr::set-action-manifest-path *action-manifest-path*)
  (setf (action-set handler) (vr::action-set "/actions/demo")
        (button-action handler) (vr::action "/actions/demo/in/HideCubes")
        (pose-action handler) (vr::action "/actions/demo/in/Hand_Right")))

(defmethod trial:stop :after ((handler vr-input-handler))) ; nothing for now...

(defclass pose-event (trial:event)
  ((data :initarg :data :accessor data)))

(defmethod trial:poll-input :after ((handler vr-input-handler)) ; from 3b-openvr-hello
  (vr::update-action-state (vector (make-instance 'vr::active-action-set
                                                  :action-set-handle (action-set handler)
                                                  :restricted-to-device
                                                  vr::+invalid-input-value-handle+
                                                  :secondary-action-set
                                                  vr::+invalid-action-set-handle+
                                                  :priority 1
                                                  :padding 0)))
  (handler-case
      (setf (pose handler)
            (dummy (vr::device-to-absolute-tracking
                    (vr::pose
                     (vr::pose-action-data-relative-to-now (pose-action handler) :standing 0.0))))
            (button handler)
            (vr::digital-action-data (button-action handler)))
    
    (t () (progn ))))
