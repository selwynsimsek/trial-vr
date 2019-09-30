(defsystem "trial-vr"
  :version "0.1.0"
  :author "Selwyn Simsek"
  :license ""
  :depends-on ("trial-glfw"
               "3b-openvr-hello"
               "cl-xwd")
  :components ((:module "src"
                :components
                ((:file "main"))))
  :description ""
  :in-order-to ((test-op (test-op "trial-vr/tests"))))

(defsystem "trial-vr/tests"
  :author "Selwyn Simsek"
  :license ""
  :depends-on ("trial-vr"
               "rove")
  :components ((:module "tests"
                :components
                ((:file "main"))))
  :description "Test system for trial-vr"
  :perform (test-op (op c) (symbol-call :rove :run c)))
