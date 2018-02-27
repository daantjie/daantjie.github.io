#lang racket/base

(require racket/date txexpr pollen/setup pollen/decode; hyphenate)
         )
(provide (all-defined-out))

(module setup racket/base
  (provide (all-defined-out))
  (require pollen/setup racket/list)
  (define poly-targets '(html))
  #;(define block-tags (remove* '(div aside) default-block-tags))
  )

(define (root . items)
  (decode (txexpr 'root '() items)
          #:txexpr-elements-proc decode-paragraphs-no-breaks
          #:block-txexpr-proc (compose1 ;hyphenate
                                wrap-hanging-quotes)
          #:string-proc (compose1 smart-quotes)
          #:exclude-tags '(style script)))

(define (decode-paragraphs-no-breaks elements)
  (decode-paragraphs elements #:linebreak-proc no-decode-linebreaks))

(define (no-decode-linebreaks elements)
  (decode-linebreaks elements " "))

(define (quotation #:person person #:source (source '()) . body)
  (case (current-poly-target)
    [(html) `(div ((class "quotation"))
                  (div "«" ,@body "»")
                  (div ((style "padding-left: 2em;"))
                       (em ,person ,@(if (null? source)
                                         '() `(" in ‘" ,source "’")))))]
    [else (list person source body)]))

(define (simple-tag tag-alist)
  (lambda body
    (let* ((target*tag (assoc (current-poly-target) tag-alist))
           (tag (if target*tag (cadr target*tag) #f)))
      (if tag `(,tag ,@body) body))))

(define (speech . elements)
  `(span "«" ,@elements "»"))

(define (title . elements)
  (case (current-poly-target)
    [(html) `(h1 ,@elements)]
    [else elements]))

(define (section . elements)
  (case (current-poly-target)
    [(html) `(h2 ,@elements)]
    [else elements]))

(define italic (simple-tag '((html i))))
(define emph (simple-tag '((html em))))
(define first-use emph)
(define new-thought emph)
(define code-function emph)

(define subtitle italic)
(define author italic)


(define (scare . saetz)
  (case (current-poly-target)
    [(html) `(span "‘" ,@saetz "’")]
    [else saetz]))


(define (aside . body)
  (case (current-poly-target)
    [(html) `(span ((class "sidenote"))
                   ,@body)]
    [else body]))

(define (code . body)
  (case (current-poly-target)
    [(html) `(code ((style "font-size: 16px;"))
                   ,@body)]))

;;; TeX utilities XXX
;; (should soon be moved to a different file)

(define (quote-tex-char c)
  (case c
    [(#\\) '(textbackslash)]
    [(#\{) '(|{|)]
    [(#\}) '(|}|)]
    [(#\$) '(|$|)]
    [(#\&) '(|&|)]
    [(#\#) '(|#|)]
    [(#\^) '(|^|)]
    [(#\_) '(|_|)]
    [(#\~) '(textasciitilde)]
    [(#\%) '(|%|)]
    [else c]))

(define (txexpr->tex tx)
  null)

;; How should this work? Does it only need to accept strings? (Because eventually
;; there will be a ‘txexpr→latex’ o.ä.)

;; That's the other thing; I'll have to choose which version of TeX to output to
;; – basically ConTeXt or LaTeX – since the two will have slightly different
;; names for things.

;; Actually, no: they both have the same *syntax* – aside from that ConTeXt
;; makes a lot of characters inactive, which shouldn't affect anything much. So
;; the main conversion function can just be ‘txexpr→tex’, since it can do the
;; same kind of conversion.

#;(define (quote-tex str))
