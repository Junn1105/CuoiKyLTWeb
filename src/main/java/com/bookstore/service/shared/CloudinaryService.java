package com.bookstore.service.shared;

import java.io.IOException;
import java.io.InputStream;
import java.util.Map;

public interface CloudinaryService {
    /**
     * Upload an image to Cloudinary or storage provider.
     * @param inputStream image stream
     * @param originalFilename original name of the file
     * @param folder folder in cloud storage (e.g. "buyback")
     * @return Map containing "publicId" and "url"
     */
    Map<String, String> uploadImage(InputStream inputStream, String originalFilename, String folder) throws IOException;

    /**
     * Delete an image by its publicId.
     */
    void deleteImage(String publicId) throws IOException;
}
