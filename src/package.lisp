(defpackage :org.shirakumo.fraf.trial.vr
  (:use :cl)
  (:local-nicknames (#:vr #:3b-openvr)
		    (#:trial #:org.shirakumo.fraf.trial)
		    #-windows (#:alloy #:org.shirakumo.alloy)
		    #-windows (#:trial-alloy #:org.shirakumo.fraf.trial.alloy)
                    ))

#+windows
(defpackage :org.shirakumo.fraf.trial.vr.windows
  (:use #:cl)
  (:local-nicknames (#:com-on #:org.shirakumo.com-on)
                    (#:com-on.cffi #:org.shirakumo.com-on.cffi)
                    (#:trial-vr #:org.shirakumo.fraf.trial.vr)))
