package com.smartfridge.repository;

import com.smartfridge.model.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
// Repositorio JPA para la entidad User, proporciona métodos CRUD
public interface UserRepository extends JpaRepository<User, Long> 
{
    // Busca un usuario por nombre de usuario y contraseña
    Optional<User> findByUsernameAndPassword(String username, String password);
    // Busca un usuario por correo electronico y contraseña
    Optional<User> findByEmailAndPassword(String email, String password);
     // Busca un usuario por nombre de usuario
    Optional<User> findByUsername(String username);
    // Busca un usuario por correo electronico
    Optional<User> findByEmail(String email);
    // Verifica si ya existe un usuario con ese nombre de usuario
    boolean existsByUsername(String username);
    // Verifica si ya existe un usuario con ese correo electrónico
    boolean existsByEmail(String email);
}
