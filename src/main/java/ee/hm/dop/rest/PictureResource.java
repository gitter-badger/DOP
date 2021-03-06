package ee.hm.dop.rest;

import static ee.hm.dop.utils.ConfigurationProperties.MAX_FILE_SIZE;
import static ee.hm.dop.utils.FileUtils.read;
import static org.apache.commons.codec.binary.Base64.decodeBase64;

import java.io.InputStream;
import java.net.HttpURLConnection;

import javax.annotation.security.RolesAllowed;
import javax.inject.Inject;
import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

import org.apache.commons.configuration.Configuration;
import org.apache.http.HttpHeaders;
import org.glassfish.jersey.media.multipart.FormDataParam;

import ee.hm.dop.model.Picture;
import ee.hm.dop.service.PictureService;

@Path("picture")
public class PictureResource extends BaseResource {

    @Inject
    private PictureService pictureService;

    @Inject
    private Configuration configuration;

    @GET
    @Path("/{name}")
    @Produces("image/png")
    public Response getPictureDataByName(@PathParam("name") String pictureName) {
        Picture picture = pictureService.getByName(pictureName);

        if (picture != null) {
            byte[] data = picture.getData();
            return Response.ok(data).header(HttpHeaders.CACHE_CONTROL, "max-age=31536000").build();
        }

        return Response.status(HttpURLConnection.HTTP_NOT_FOUND).build();
    }

    @POST
    @RolesAllowed({ "USER", "ADMIN" })
    @Produces(MediaType.APPLICATION_JSON)
    @Consumes(MediaType.MULTIPART_FORM_DATA)
    public Picture uploadPicture(@FormDataParam("picture") InputStream fileInputStream) {
        byte[] dataBase64 = read(fileInputStream, configuration.getInt(MAX_FILE_SIZE));
        byte[] data = decodeBase64(dataBase64);

        Picture picture = new Picture();
        picture.setData(data);
        return pictureService.create(picture);
    }

    @GET
    @Path("/maxSize")
    @Produces(MediaType.APPLICATION_JSON)
    public int getMaxSize() {
        return configuration.getInt(MAX_FILE_SIZE);
    }
}
