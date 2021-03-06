package ee.hm.dop.utils;

import static java.lang.String.format;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.net.URISyntaxException;
import java.net.URL;
import java.util.Arrays;

import org.apache.commons.io.Charsets;
import org.apache.commons.io.IOUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class FileUtils {
    private static final Logger logger = LoggerFactory.getLogger(FileUtils.class);

    private static final int MB_TO_B_MULTIPLIER = 1024 * 1024;

    public static InputStream getFileAsStream(String filePath) {
        logger.info(format("Getting file from %s", filePath));
        File file = new File(filePath);

        if (file.exists()) {
            try {
                return new FileInputStream(file);
            } catch (FileNotFoundException e) {
                throw new RuntimeException(e);
            }
        }

        logger.info(format("File %s does not exist. Trying to load from classpath.", filePath));

        return FileUtils.class.getClassLoader().getResourceAsStream(filePath);
    }

    public static File getFile(String filePath) {
        logger.info(format("Getting file from %s", filePath));
        File file = new File(filePath);

        if (!file.exists()) {
            logger.info(format("File %s does not exist. Trying to load from classpath.", filePath));

            URL resource = FileUtils.class.getClassLoader().getResource(filePath);
            if (resource != null) {
                try {
                    file = new File(resource.toURI());
                } catch (URISyntaxException e) {
                    throw new RuntimeException(e);
                }
            }
        }

        return file;
    }

    public static String readFileAsString(String filePath) {
        InputStream in = null;
        try {
            in = getFileAsStream(filePath);
            return IOUtils.toString(in, Charsets.UTF_8);
        } catch (IOException e) {
            throw new RuntimeException(e);
        } finally {
            IOUtils.closeQuietly(in);
        }
    }

    /**
     * Read the inputStream till the maxSize. Throws an Exception if file is
     * bigger than maxSize.
     * 
     * @param inputStream
     *            the file to be read
     * @param maxSize
     *            the max size in MB.
     * @return the read file as bytes
     */
    public static byte[] read(InputStream inputStream, int maxSize) {
        // Size is in MB
        int maxFileSize = maxSize * MB_TO_B_MULTIPLIER;
        byte[] bytes = new byte[maxFileSize + 1];

        int read = -1;
        try {
            read = IOUtils.read(inputStream, bytes);
            if (read > maxFileSize) {
                throw new RuntimeException("File bigger than max size allowed");
            }
        } catch (IOException e) {
            throw new RuntimeException(e);
        }

        return Arrays.copyOf(bytes, read);
    }
}
