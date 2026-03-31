 ------------------------- USER SETTINGS -------------------------
var region = fire.geometry().buffer(1);        1 m clean-up buffer
 (or buffer(1).buffer(-1) for a morphological clean)


 Date windows (edit as needed)
var preStart  = '2025-05-15';
var preEnd    = '2025-06-24';    day before fire
var postStart = '2025-07-25';
var postEnd   = '2025-08-10';    includes ~Aug 2

 Export settings
var outScale  = 20;              meters (matches SWIR bands)
var outCRS    = 'EPSG4326';     or 'EPSG27700' for British National Grid
var outFolder = 'Scotland_fire';   Drive folder

 ------------------------- HELPERS -------------------------

 Cloudshadowsnowwater mask using SCL (Scene Classification) band.
 Keep vegetation (4), bare soil (5), optionally dark (2).
function maskS2_SCL(img) {
  var scl = img.select('SCL');
  var keep = scl.eq(4).or(scl.eq(5)).or(scl.eq(2));  vegetation, bare soil, dark
   Optionally keep water (6) by keep = keep.or(scl.eq(6));
  return img.updateMask(keep);
}

 Build a cloud-masked, clipped collection for a given date window.
function s2Collection(start, end) {
  return ee.ImageCollection('COPERNICUSS2_SR_HARMONIZED')
    .filterBounds(region)
    .filterDate(start, end)
    .map(maskS2_SCL)
     Select NIR and SWIR2 (NBR bands). 10m+20m we’ll export at 20m.
    .select(['B8','B12']);
}

 Make a robust median composite (you can change to .median(), .mosaic(), or percentile).
function composite(ic) {
   median is robust to residual clouds
  return ic.median().clip(region);
}

 Compute indices NBR, dNBR, RdNBR, RBR
function addSeverity(pre, post) {
  var preNBR  = pre.normalizedDifference(['B8','B12']).rename('NBR_pre');
  var postNBR = post.normalizedDifference(['B8','B12']).rename('NBR_post');
  var dNBR    = preNBR.subtract(postNBR).rename('dNBR');

   RdNBR per Miller & Thode (2007) dNBR  sqrt(preNBR)
  var preNBRabs = preNBR.abs().max(ee.Image.constant(0.001));  avoid 0
  var RdNBR     = dNBR.divide(preNBRabs.sqrt()).rename('RdNBR');

   RBR (Parks et al. 2018) dNBR  (preNBR + 1.001)
  var RBR = dNBR.divide(preNBR.add(1.001)).rename('RBR');

  return preNBR.addBands([postNBR, dNBR, RdNBR, RBR]).clip(region);
}

 ------------------------- PIPELINE -------------------------

 Build composites
var preIC  = s2Collection(preStart,  preEnd);
var postIC = s2Collection(postStart, postEnd);

print('Pre-fire image count', preIC.size());
print('Post-fire image count', postIC.size());

var preComp  = composite(preIC);
var postComp = composite(postIC);

 Compute burn severity metrics
var sev = addSeverity(preComp, postComp);

 ------------------------- VIEW -------------------------

Map.centerObject(region, 11);
Map.addLayer(preComp,  {bands['B8','B12','B8'], min0.03, max0.3}, 'Pre composite (B8B12B8)');
Map.addLayer(postComp, {bands['B8','B12','B8'], min0.03, max0.3}, 'Post composite (B8B12B8)');

var vizNBR  = {min-0.5, max1.0, palette['#7f2704','#f46d43','#fdae61','#ffffbf','#a6d96a','#1a9850','#00441b']};
var vizdNBR = {min-0.5, max1.0, palette['#2c7bb6','#abd9e9','#ffffbf','#fdae61','#f46d43','#d73027']};
var vizRdNBR= {min0,   max1.5, palette['#ffffcc','#c7e9b4','#7fcdbb','#41b6c4','#1d91c0','#225ea8','#0c2c84']};
var vizRBR  = {min-0.5, max1.0, palette['#2c7bb6','#abd9e9','#ffffbf','#fdae61','#f46d43','#d73027']};

Map.addLayer(sev.select('NBR_pre'),  vizNBR,  'NBR pre');
Map.addLayer(sev.select('NBR_post'), vizNBR,  'NBR post');
Map.addLayer(sev.select('dNBR'),     vizdNBR, 'dNBR');
Map.addLayer(sev.select('RdNBR'),    vizRdNBR,'RdNBR');
Map.addLayer(sev.select('RBR'),      vizRBR,  'RBR');

 ------------------------- EXPORTS -------------------------

 Prepost composites (B8 & B12) are useful to keep
Export.image.toDrive({
  image preComp.select(['B8','B12']),
  description 'Carr_S2_PreComposite_B8B12',
  folder outFolder,
  fileNamePrefix 'Carr_Pre_B8B12',
  region region,
  scale outScale,
  crs outCRS,
  maxPixels 1e13
});

Export.image.toDrive({
  image postComp.select(['B8','B12']),
  description 'Carr_S2_PostComposite_B8B12',
  folder outFolder,
  fileNamePrefix 'Carr_Post_B8B12',
  region region,
  scale outScale,
  crs outCRS,
  maxPixels 1e13
});

 Export severity rasters
Export.image.toDrive({
  image sev.select('dNBR'),
  description 'Carr_dNBR',
  folder outFolder,
  fileNamePrefix 'Carr_dNBR',
  region region,
  scale outScale,
  crs outCRS,
  maxPixels 1e13
});

Export.image.toDrive({
  image sev.select('RdNBR'),
  description 'Carr_RdNBR',
  folder outFolder,
  fileNamePrefix 'Carr_RdNBR',
  region region,
  scale outScale,
  crs outCRS,
  maxPixels 1e13
});

Export.image.toDrive({
  image sev.select('RBR'),
  description 'Carr_RBR',
  folder outFolder,
  fileNamePrefix 'Carr_RBR',
  region region,
  scale outScale,
  crs outCRS,
  maxPixels 1e13
});


