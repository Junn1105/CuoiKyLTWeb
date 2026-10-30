package com.bookstore.service.shared;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

public class MockCloudinaryServiceImpl implements CloudinaryService {

    private static final Logger log = LoggerFactory.getLogger(MockCloudinaryServiceImpl.class);

    @Override
    public Map<String, String> uploadImage(InputStream inputStream, String originalFilename, String folder) throws IOException {
        String publicId = folder + "/" + UUID.randomUUID();
        String fakeUrl = "https://res.cloudinary.com/demo/image/upload/" + publicId + ".jpg";
        log.info("[MOCK Cloudinary] Simulated upload for '{}' -> publicId: '{}', url: '{}'", originalFilename, publicId, fakeUrl);

        Map<String, String> result = new HashMap<>();
        result.put("publicId", publicId);
        result.put("url", fakeUrl);
        return result;
    }

    @Override
    public void deleteImage(String publicId) throws IOException {
        log.info("[MOCK Cloudinary] Simulated delete for publicId: '{}'", publicId);
    }
}
