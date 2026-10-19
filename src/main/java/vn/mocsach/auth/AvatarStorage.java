package vn.mocsach.auth;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import javax.imageio.ImageIO;
import java.awt.RenderingHints;
import java.awt.image.BufferedImage;
import java.io.*;
import java.nio.file.*;
import java.util.UUID;

@Service
public class AvatarStorage {
 private final Path root;
 public AvatarStorage(@Value("${app.avatar.directory:.local/avatars}") String directory){root=Path.of(directory).toAbsolutePath().normalize();}
 public String save(MultipartFile file) {
  if(file==null||file.isEmpty()||file.getSize()>5*1024*1024) throw new AuthProblem("Chọn ảnh JPG hoặc PNG không quá 5 MB.");
  try(var input=ImageIO.createImageInputStream(new ByteArrayInputStream(file.getBytes()))) {
   var readers=ImageIO.getImageReaders(input);
   if(!readers.hasNext()) throw new AuthProblem("File không phải ảnh JPG hoặc PNG hợp lệ.");
   var reader=readers.next();
   try {
    String format=reader.getFormatName();
    if(!format.equalsIgnoreCase("png")&&!format.equalsIgnoreCase("jpeg")) throw new AuthProblem("Chỉ hỗ trợ ảnh JPG hoặc PNG.");
    reader.setInput(input,true,true);int w=reader.getWidth(0),h=reader.getHeight(0);
    if(w<1||h<1||w>4096||h>4096) throw new AuthProblem("Kích thước ảnh tối đa là 4096 × 4096 pixel.");
    BufferedImage source=reader.read(0),output=new BufferedImage(384,384,BufferedImage.TYPE_INT_RGB);
    var g=output.createGraphics();
    try {g.setColor(java.awt.Color.WHITE);g.fillRect(0,0,384,384);g.setRenderingHint(RenderingHints.KEY_INTERPOLATION,RenderingHints.VALUE_INTERPOLATION_BICUBIC);int side=Math.min(w,h),x=(w-side)/2,y=(h-side)/2;g.drawImage(source,0,0,384,384,x,y,x+side,y+side,null);} finally {g.dispose();}
    Files.createDirectories(root);String name=UUID.randomUUID()+".png";
    try(var out=Files.newOutputStream(root.resolve(name),StandardOpenOption.CREATE_NEW)){ImageIO.write(output,"png",out);}
    return name;
   } finally {reader.dispose();}
  } catch(IOException ex){throw new AuthProblem("Không lưu được ảnh. Vui lòng thử ảnh khác hoặc thử lại sau.");}
 }
 public byte[] read(String name)throws IOException {
  if(name==null||!name.matches("[a-f0-9-]{36}\\.png")) return null;
  Path path=root.resolve(name);return Files.isRegularFile(path)?Files.readAllBytes(path):null;
 }
 public void delete(String name){if(name!=null&&name.matches("[a-f0-9-]{36}\\.png"))try{Files.deleteIfExists(root.resolve(name));}catch(IOException ignored){/* An unused image can be cleaned up later. */}}
}
