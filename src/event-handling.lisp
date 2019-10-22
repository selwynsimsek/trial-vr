;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; Hooks controller input into the trial event handling system.

(in-package :trial-vr)

(defclass vr-input-handler () ())

(defclass event (trial:event) ())

(defclass vr-event (event)
  ((tracked-device-index :initarg :tracked-device-index :accessor tracked-device-index)
   (age :initarg :event-age :accessor age)))

(defclass controller-event (vr-event)
  ((button-id :initarg :button-id :accessor button-id)))

(defclass mouse-event (vr-event)
  ((x :initarg :x :accessor x)
   (y :initarg :y :accessor y)
   (mouse-button :initarg :mouse-button :accessor mouse-button)))

(defclass process-event (vr-event)
  ((pid :initarg :pid :accessor pid)
   (old-pid :initarg :pid :accessor old-pid)))

(defclass controller-state (event)
  ((packet-num :initarg :packet-num :accessor packet-num)
   (button-pressed :initarg :button-pressed :accessor button-pressed)
   (button-touched :initarg :button-touched :accessor button-touched)
   (axis :initarg :axis :accessor axis)))

(defmethod trial:start :after ((handler vr-input-handler))
  (vr::vr-system))

(defmethod trial:stop :after ((handler vr-input-handler))) ; nothing for now...

;; (defun process-vr-event () ; from 3b-openvr
;;   (cffi:with-foreign-object (event '(:struct vr::vr-event-t))
;;     (when (vr::%poll-next-event (table vr::*system*) event (cffi:foreign-type-size
;;                                                             '(:struct vr::vr-event-t)))
;;       (cffi:with-foreign-slots (vr::event-type vr::tracked-device-index event-age-seconds data)
        
;;         (make-instance 'vr-event)))))

(defun process-controller-state (device)
  (cffi:with-foreign-object (controller-state '(:struct vr::vr-controller-state-001-t))
    (when (vr::%get-controller-state (vr::table vr::*system*)
                                     device
                                     controller-state
                                     (cffi:foreign-type-size
                                      '(:struct vr::vr-controller-state-001-t)))
      (cffi:with-foreign-slots ((vr::packet-num vr::button-pressed vr::button-touched (:pointer vr::axis))
                                controller-state
                                (:struct vr::vr-controller-state-001-t))
        (let ((axis-array (make-array '(5 2) :initial-element 0.0d0)))
          (loop for index below 5 do
                (let ((foreign-axis (cffi:mem-aref vr::axis '(:struct vr::vr-controller-axis-t) index)))
                  (setf (aref axis-array index 0) (second foreign-axis)
                        (aref axis-array index 1) (fourth foreign-axis))))
          (make-instance 'controller-state
                         :packet-num vr::packet-num
                         :button-pressed vr::button-pressed
                         :button-touched vr::button-touched
                         :axis axis-array))))))

(defmethod trial:poll-input :after ((handler vr-input-handler)) ; from 3b-openvr-hello
  ;; (loop for event = (process-vr-event)
  ;;       while event
  ;;       do (trial:handle event handler))
  (loop for device below vr::+max-tracked-device-count+
        for state = (process-controller-state device)
        do (when state
             (trial:handle state handler))))
