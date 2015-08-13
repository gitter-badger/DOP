package ee.hm.dop.dao;

import java.util.List;

import javax.inject.Inject;
import javax.persistence.EntityManager;
import javax.persistence.NoResultException;
import javax.persistence.TypedQuery;

import ee.hm.dop.model.Material;

public class MaterialDAO {

    @Inject
    private EntityManager entityManager;

    public Material findById(long materialId) {
        TypedQuery<Material> findByCode = entityManager.createQuery("SELECT m FROM Material m WHERE m.id = :id",
                Material.class);

        Material material = null;
        try {
            material = findByCode.setParameter("id", materialId).getSingleResult();
        } catch (NoResultException ex) {
            // ignore
        }

        return material;
    }

    /**
     * finds all materials contained in the idList. There is no guarantee about
     * in which order the materials will be in the result list.
     *
     * @param idList
     *            the list with materials id
     * @return a list of materials specified by idList
     */
    public List<Material> findAllById(List<Long> idList) {
        TypedQuery<Material> findAllByIdList = entityManager.createQuery(
                "SELECT m FROM Material m WHERE m.id in :idList", Material.class);
        return findAllByIdList.setParameter("idList", idList).getResultList();
    }

    public List<Material> findNewestMaterials(int numberOfMaterials) {

        return entityManager.createQuery("from Material order by added desc", Material.class)
                .setMaxResults(numberOfMaterials).getResultList();
    }

    public void update(Material material) {
        entityManager.persist(material);
    }

    /**
     * For testing purposes.
     *
     * @param material
     */
    public void delete(Material material) {
        entityManager.remove(material);
    }

    public byte[] findPictureByMaterial(Material material) {
        TypedQuery<byte[]> findById = entityManager.createQuery("SELECT m.picture FROM Material m WHERE m.id = :id",
                byte[].class);

        byte[] picture = null;
        try {
            picture = findById.setParameter("id", material.getId()).getSingleResult();
        } catch (NoResultException ex) {
            // ignore
        }

        return picture;
    }
}
