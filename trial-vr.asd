(defsystem "trial-vr"
  :version "0.1.0"
  :author "Selwyn Simsek"
  :license ""
  :depends-on ("trial-glfw"
               "3b-openvr"
               "sb-cga"
               "cl-steamworks"
               "cl-ode"
               "bordeaux-threads"
               "cl-xwd"
               "trial-assimp"
               "harmony-simple")
  :components ((:module "src"
                :components
                ((:file "package")
                 (:file "actor")
                 (:file "environment" :depends-on ("workbench"))
                 (:file "emacs-cube")
                 (:file "workbench")
                 (:file "low-level")
                 (:file "rendering")
                 (:file "event-handling")
                 (:file "physics")
                 (:file "particle")
                 (:file "debug")
                 (:file "controllers"))))
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
