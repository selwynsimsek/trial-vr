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
   (overlays :initarg :overlays :initform #()  :accessor overlays)
   (render-needed-p :initarg :render-needed-p :initform t :accessor render-needed-p)
   (number-of-overlays :initarg :number-of-overlays :accessor number-of-overlays :initform 4)
   (debug-overlay :initform (make-instance 'vr:overlay) :accessor debug-overlay)
   (dui :initarg :dui :initform nil :accessor dui))
  (:default-initargs :name :ui-render-pass))

;(defmethod trial:compile-to-pass (object (pass ui-render-pass)))
;(defmethod trial:compile-into-pass (object container (pass ui-render-pass)))
;(defmethod trial:remove-from-pass (object (pass ui-render-pass)))


(defvar *vec* nil)
(defun make-layout (focus dui n)
  (let* ((layout-1 (make-instance 'alloy:grid-layout  
                                  :layout-parent (org.shirakumo.alloy:layout-tree dui)
                                  :col-sizes (make-array (list n) :initial-element t)
                                  :row-sizes (make-array (list n) :initial-element t)))
         (data (3d-vectors:vec2 0 n))
         ;(vec (org.shirakumo.alloy:represent data 'trial-alloy::vec2   :focus-parent focus :layout-parent layout-1))
         )
   (alloy::adjust-grid layout-1 n n)
    (loop for i below (* n n) do
          (let ((vec (org.shirakumo.alloy:represent (format nil "~a" i) 'alloy:label)))
           ; (break)
            (setf *vec* vec)
            (org.shirakumo.alloy:register vec dui)
            (alloy:enter vec layout-1 :row (mod i n) (floor (/ i n)))
            (alloy:on alloy:value (value vec)
              (print value))))
    layout-1))

(defmethod initialize-instance :after ((instance ui-render-pass) &key)
  (vr:show (debug-overlay instance))
  (let* ((overlay-side (1+ (isqrt (1- (number-of-overlays instance)))))
         (ui (dui instance))
         (focus-1 (make-instance 'alloy:focus-list :focus-parent (alloy:focus-tree ui)))
         (layout-1 (make-layout focus-1 ui overlay-side)))
    
    (setf (overlays instance)
          (coerce (loop repeat (number-of-overlays instance)
                        collect (make-instance 'vr:overlay))
                  'vector))
    (loop for i from 0 below overlay-side do
          (loop for j from 0 below overlay-side do
                (let ((index (+ i (* overlay-side j))))
                  (when (< index (length (overlays instance)))
                    (progn
                      (setf (vr:texture-bounds (aref (overlays instance) index))
                            (vector (* i (/ overlay-side)) (* j (/ overlay-side))
                                    (* (1+ i) (/ overlay-side)) (* (1+ j) (/ overlay-side))))
                      (setf (vr:location (aref (overlays instance) index))
                            (vector (* i 0.1) (* j 0.1) (* i 0.1))))))))
    (map nil #'vr:show (overlays instance))))

(defmethod trial:render :after
    ((pass ui-render-pass) (arg (eql nil)))
  (let ((texture-id (trial:data-pointer (trial:texture (flow:port pass 'trial:color))))
        (overlays (overlays pass)))
    (map nil (lambda (overlay) (setf (vr:texture overlay) texture-id)) overlays)
                                        ; change this to render only when the underlying texture is changed; very wasteful at the moment
   ; (break)
    (setf (vr:texture (debug-overlay pass)) texture-id)
    (setf (vr:transform (debug-overlay pass))
          (make-instance 'vr::absolute-transform :origin :standing :matrix #(0.0 0.0 1.0 -1.0
                                                                             0.0 1.0 0.0 1.0
                                                                             -1.0 0.0 0.0 0.0)))))

(defmethod (setf org.shirakumo.alloy::render-needed-p) :after (value (object org.shirakumo.alloy:renderable))
  (setf (render-needed-p  (aref (trial:passes (trial:scene (trial:handler trial:*context*))) 2) ) t)); :(

(defmethod trial:render :around ((pass ui-render-pass) arg)
  (call-next-method)
  ;; (when (render-needed-p pass)
  ;;   (call-next-method)
  ;;   (setf (render-needed-p pass) nil))
  )


(defun set-overlay-visibility (visible-p key)
  (if visible-p
      (vr:show-overlay (vr:find-overlay key))
      (vr:hide-overlay (vr:find-overlay key))))

(defun set-overlay-displacement (key x y z)
  (vr:set-overlay-transform-absolute
   (vr:find-overlay key) :standing (vector 1.0 0.0 0.0 x
                                           0.0 1.0 0.0 y
                                           0.0 0.0 1.0 z)))
