;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Hooks controller input into the trial event handling system.

(in-package #:org.shirakumo.trial.vr)

(defclass vr-input-handler ()
  ((action-set :initarg :action-set :initform nil :accessor action-set)
   (actions :initarg :actions :initform nil :accessor actions)))

(defvar *action-manifest-path*
  (namestring (truename (asdf:system-relative-pathname :trial-vr #p"assets/actions.json"))))

(defvar *action-set-name* "/actions/trial_vr")

(defmethod trial:start :after ((handler vr-input-handler))
  (vr::set-action-manifest-path *action-manifest-path*)
  (setf (action-set handler) *action-set-name*
        (actions handler) (vr::manifest-actions *action-manifest-path*)))

(defmethod trial:stop :after ((handler vr-input-handler))) ; nothing for now...

(defclass pose-event (trial:event)
  ((data :initarg :data :accessor data)))

(defmethod trial:poll-input :after ((handler vr-input-handler)) ; from 3b-openvr-hello
  (vr::update-action-set (action-set handler))
  (map nil #'vr::update-data (actions handler)))

(defun find-action (action-name input-handler)
  (find action-name (actions input-handler) :key #'vr::name :test #'string=))

(defun controller-pose ()
  "Convenience method to return the pose of either connected controller. Not good to use this in production."
  (handler-case
      (let ((left-pose (vr::pose (vr::action-data (find-action "/actions/trial_vr/in/Hand_Left"
                                                               (trial:handler trial:*context*)))))
            (right-pose (vr::pose (vr::action-data (find-action "/actions/trial_vr/in/Hand_Right"
                                                                (trial:handler trial:*context*))))))
        (if (eq :running-ok (vr::tracking-result left-pose))
            (vr::device-to-absolute-tracking left-pose)
            (when (eq :running-ok (vr::tracking-result right-pose))
              (vr::device-to-absolute-tracking right-pose))))
    (t () (progn ))))

(defun controller-pose-for-handedness (handedness)
  (handler-case
      (cond
        ((eq handedness :left)
         (vr::pose (vr::action-data (find-action "/actions/trial_vr/in/Hand_Left"
                                                 (trial:handler trial:*context*)))))
        ((eq handedness :right)
         (vr::pose (vr::action-data (find-action "/actions/trial_vr/in/Hand_Right"
                                                 (trial:handler trial:*context*))))))
    (t () nil)))
