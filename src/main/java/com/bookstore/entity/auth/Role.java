package com.bookstore.entity.auth;

import jakarta.persistence.*;

@Entity
@Table(name = "bk_roles")
public class Role {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    @Column(name = "code", unique = true, nullable = false, length = 50)
    private RoleCode code;

    @Column(name = "name", nullable = false, length = 100)
    private String name;

    public Role() {
    }

    public Role(RoleCode code, String name) {
        this.code = code;
        this.name = name;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public RoleCode getCode() {
        return code;
    }

    public void setCode(RoleCode code) {
        this.code = code;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }
}
