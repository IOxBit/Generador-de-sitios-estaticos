#lang racket

(require markdown)


;;================;;
;;OBTENER ARCHIVOS

(define (obtener-lista-de-archivos)
  (obtener-lista-de-archivos-aux (directory-list "contenido" #:build? #t)))

(define (obtener-lista-de-archivos-aux lat)
  (cond
    [(null? lat) '()]
    [(path-has-extension? (car lat) ".md")
     (cons (path->string  (car lat))
           (obtener-lista-de-archivos-aux (cdr lat)))]
    [else (obtener-lista-de-archivos-aux (cdr lat))]))

;;-------------------------


;;================;;
;;LEER ARCHIVOS

(define (leer ruta)
  (file->string ruta))

(define (leer-todos lat)
  (cond
    [(null? lat) '()]
    [else (cons (leer (car lat))
                (leer-todos (cdr lat)))]))

;;-------------------------


;;================;;
;;COMBINAR

(define (lista-a-mega-string lat)
  (cond
    [(null? lat) ""]
    [(null? (cdr lat)) (car lat)]
    [else (string-append (car lat)
                         "\n\n---\n\n"
                         (lista-a-mega-string (cdr lat)))]))

;;-------------------------


;;================;;
;;PARSING

(define (envolver-en-html lista-contenido)
  (list 'html
        (list 'head
              (list 'title "Mi Sitio Generado"))
        (list 'style
              "body { font-family: sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; }"
                    "img { max-width: 100%; }"
                    "pre { background: #f4f4f4; padding: 10px; border-radius: 5px; }")
        (cons 'body lista-contenido)))

;;-------------------------


;;================;;
;;ESCRITURA


(define (escribir contenido)
  (with-output-to-file "salida/index.html"
    (λ ()
      (displayln "<!DOCTYPE html>")
      (display contenido))
    #:exists 'replace))

;;-------------------------


;;================;;
;;EJECUCION

(define archivos (obtener-lista-de-archivos))
(define textos (leer-todos archivos))
(define unido (lista-a-mega-string textos))
(define s-exps (parse-markdown unido))
(define arbol (envolver-en-html s-exps))
(define html-str (xexpr->string arbol))

(unless (directory-exists? "salida")
  (make-directory "salida"))
(escribir html-str)

(displayln "sitio generado")