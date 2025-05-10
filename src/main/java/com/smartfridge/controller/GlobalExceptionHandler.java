package com.smartfridge.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import java.util.Map;

@RestControllerAdvice
// Maneja excepciones globalmente en los controladores
public class GlobalExceptionHandler {
    @ExceptionHandler(Exception.class)
    // Maneja cualquier excepción y devuelve un mensaje de error
    public ResponseEntity<?> handleAllExceptions(Exception e) {
        String msg = e.getMessage();
        if (msg == null || msg.isEmpty()) {
            msg = "Ha ocurrido un error inesperado. Inténtalo de nuevo más tarde.";
        }
        return ResponseEntity.badRequest().body(Map.of("message", msg));
    }
}