;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Hooks controller input into the trial event handling system.

(in-package :trial-vr)

(defclass vr-input-handler ()
  ((action-set :initarg :action-set :initform nil :accessor action-set)
   (pose-action :initarg :pose-action :initform nil :accessor pose-action)
   (button-action :initarg :button-action :initform nil :accessor button-action)))

(defvar *action-manifest-path* "/home/selwyn/openvr/samples/bin/hellovr_actions.json")

(defmethod trial:start :after ((handler vr-input-handler))
  (setf vr::*input* nil)
  (vr::vr-input)
  (vr::set-action-manifest-path *action-manifest-path*)
  (setf (action-set handler) (vr::action-set "/actions/demo")
        (button-action handler) (vr::action "/actions/demo/in/HideCubes")
        (pose-action handler) (vr::action "/actions/demo/in/Hand_Right")))

(defmethod trial:stop :after ((handler vr-input-handler))) ; nothing for now...

(defclass pose-event (trial:event)
  ((data :initarg :data :accessor data)))

(defmethod trial:poll-input :after ((handler vr-input-handler)) ; from 3b-openvr-hello
  ;; (loop for event = (process-vr-event)
  ;;       while event
  ;;       do (trial:handle event handler))
  (vr::update-action-state (vector (make-instance 'vr::active-action-set
                                                  :action-set-handle (vr::action-set "/actions/demo")
                                                  :restricted-to-device vr::+invalid-input-value-handle+
                                                  :secondary-action-set vr::+invalid-action-set-handle+
                                                  :priority 1
                                                  :padding 0))))

(defun pull-data ()
  (vr::pose-action-data-for-next-frame (vr::action "/actions/demo/in/Hand_Right") :seated)
  ;(vr::digital-action-data (vr::action "/actions/demo/in/HideCubes"))
)
