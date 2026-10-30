package com.bookstore.repository.catalog;

import com.bookstore.entity.catalog.BookTitle;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository("bkBookTitleRepository")
public interface BookTitleRepository extends JpaRepository<BookTitle, Long> {
    Optional<BookTitle> findByIsbn(String isbn);
    List<BookTitle> findByTitleContainingIgnoreCase(String title);
    List<BookTitle> findByCategory(String category);
}
