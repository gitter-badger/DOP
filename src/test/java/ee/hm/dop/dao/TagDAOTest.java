package ee.hm.dop.dao;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;

import javax.inject.Inject;

import org.junit.Test;

import ee.hm.dop.common.test.DatabaseTestBase;
import ee.hm.dop.model.Tag;

/**
 * Created by mart.laus on 24.07.2015.
 */
public class TagDAOTest extends DatabaseTestBase {

    @Inject
    private TagDAO tagDAO;

    @Test
    public void findTagByName() {
        Long id = new Long(1);
        String name = "matemaatika";

        Tag returnedTag = tagDAO.findTagByName(name);

        assertNotNull(returnedTag);
        assertNotNull(returnedTag.getId());
        assertEquals(id, returnedTag.getId());
        assertEquals(name, returnedTag.getName());
    }
}
