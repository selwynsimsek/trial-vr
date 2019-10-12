(defsystem "trial-vr"
  :version "0.1.0"
  :author "Selwyn Simsek"
  :license ""
  :depends-on ("trial-glfw"
               "3b-openvr"
               "sb-cga"
               "bordeaux-threads"
               "cl-xwd")
  :components ((:module "src"
                :components
                ((:file "package")
                 (:file "actor")
                 (:file "environment" :depends-on ("main"))
                 (:file "emacs-cube")
                 (:file "main")
                 (:file "low-level")
                 (:file "rendering")
                 (:file "debug"))))
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
