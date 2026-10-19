package vn.mocsach.auth;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;
import org.springframework.mock.web.MockMultipartFile;
import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.*;
import java.nio.file.*;
import static org.junit.jupiter.api.Assertions.*;
class AvatarStorageTest {
 @TempDir Path directory;
 @Test void reencodesToSquarePngAndIgnoresClientFilename()throws Exception {
  var storage=new AvatarStorage(directory.toString());var bytes=new ByteArrayOutputStream();ImageIO.write(new BufferedImage(800,600,BufferedImage.TYPE_INT_RGB),"png",bytes);
  String name=storage.save(new MockMultipartFile("avatar","../../evil.html","text/html",bytes.toByteArray()));
  assertTrue(name.matches("[a-f0-9-]{36}\\.png"));var decoded=ImageIO.read(new ByteArrayInputStream(storage.read(name)));assertEquals(384,decoded.getWidth());assertEquals(384,decoded.getHeight());assertNull(storage.read("../other.png"));storage.delete(name);assertNull(storage.read(name));
 }
 @Test void rejectsFakeImagesOversizedFilesAndHugeDimensions()throws Exception {
  var storage=new AvatarStorage(directory.toString());
  assertThrows(AuthProblem.class,()->storage.save(new MockMultipartFile("avatar","fake.png","image/png","<script>alert(1)</script>".getBytes())));
  assertThrows(AuthProblem.class,()->storage.save(new MockMultipartFile("avatar",new byte[5*1024*1024+1])));
  var out=new ByteArrayOutputStream();ImageIO.write(new BufferedImage(4097,1,BufferedImage.TYPE_INT_RGB),"png",out);
  assertThrows(AuthProblem.class,()->storage.save(new MockMultipartFile("avatar",out.toByteArray())));
 }
}
