(defpackage :org.shirakumo.fraf.trial.vr
  (:use :cl)
  (:local-nicknames (#:vr #:3b-openvr)
		    (#:trial #:org.shirakumo.fraf.trial)
		    #-win32 (#:alloy #:org.shirakumo.alloy)
		    #-win32 (#:trial-alloy #:org.shirakumo.fraf.trial.alloy)))


(defpackage :org.shirakumo.fraf.trial.vr.windows
  (:use #:cl)
  (:local-nicknames (#:com-on #:org.shirakumo.com-on)
                    (#:trial-vr #:org.shirakumo.fraf.trial.vr)))
