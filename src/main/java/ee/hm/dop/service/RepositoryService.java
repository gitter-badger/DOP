package ee.hm.dop.service;

import static java.lang.String.format;

import java.util.Collections;
import java.util.List;

import javax.inject.Inject;

import org.joda.time.DateTime;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import ee.hm.dop.dao.MaterialDAO;
import ee.hm.dop.dao.RepositoryDAO;
import ee.hm.dop.model.Material;
import ee.hm.dop.model.Repository;
import ee.hm.dop.oaipmh.MaterialIterator;
import ee.hm.dop.oaipmh.RepositoryManager;
import ee.hm.dop.utils.DbUtils;

public class RepositoryService {

    private static final int MAX_IMPORT_BEFORE_EMPTY_CACHE = 50;

    private static final Logger logger = LoggerFactory.getLogger(RepositoryService.class);

    @Inject
    private RepositoryDAO repositoryDAO;

    @Inject
    private RepositoryManager repositoryManager;

    @Inject
    private MaterialService materialService;

    @Inject
    private MaterialDAO materialDAO;

    public List<Repository> getAllRepositorys() {
        List<Repository> repositories = repositoryDAO.findAll();

        if (repositories == null) {
            repositories = Collections.emptyList();
        }

        return repositories;
    }

    public void synchronize(Repository repository) {
        logger.info(format("Updating materials for %s", repository));

        long failedMaterials = 0;
        long successfulMaterials = 0;
        long start = System.currentTimeMillis();
        DateTime startSyncDateTime;

        MaterialIterator materials;
        try {
            materials = repositoryManager.getMaterialsFrom(repository);
            startSyncDateTime = DateTime.now();
        } catch (Exception e) {
            logger.error(format("Error while getting material from %s. No material will be updated.", repository), e);
            return;
        }

        int count = 0;
        while (materials.hasNext()) {
            try {
                Material material = materials.next();
                handleMaterial(repository, material);
                successfulMaterials++;
            } catch (Exception e) {
                logger.error("An error occurred while getting the next material from repository.", e);
                failedMaterials++;
            }

            count = getCount(count);
        }

        repository.setLastSynchronization(startSyncDateTime);
        updateRepositoryData(repository);

        long end = System.currentTimeMillis();
        String message = "Updating materials took %s milliseconds. Successfully downloaded %s"
                + " materials and %s materials failed to download of total %s";
        logger.info(format(message, end - start, successfulMaterials, failedMaterials, successfulMaterials
                + failedMaterials));
    }

    private int getCount(int count) {
        if (++count >= MAX_IMPORT_BEFORE_EMPTY_CACHE) {
            DbUtils.emptyCache();
            count = 0;
        }
        return count;
    }

    private void handleMaterial(Repository repository, Material material) {
        if (material != null) {
            Material existentMaterial = materialDAO.findByRepositoryAndRepositoryIdentifier(repository,
                    material.getRepositoryIdentifier());

            material.setRepository(repository);

            if (existentMaterial != null) {
                material.setId(existentMaterial.getId());
                materialService.update(material);
            } else {
                materialService.createMaterial(material);
            }
        }
    }

    public void updateRepositoryData(Repository repository) {
        repositoryDAO.updateRepository(repository);
    }
}
