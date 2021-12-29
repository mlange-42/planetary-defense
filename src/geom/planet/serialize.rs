use csv::Reader;
use gdnative::core_types::Vector3;
use std::error::Error;
use std::fs::File;
use std::path::Path;

use crate::geom::planet::data::{NodeNeighbors, PlanetData, PlanetProperties};
use crate::NodeData;

pub fn to_csv<P: AsRef<Path>>(data: &PlanetData, path: &P) -> Result<(), Box<dyn Error>> {
    let mut wtr = csv::WriterBuilder::new()
        .has_headers(false)
        .delimiter(b';')
        .flexible(true)
        .from_path(path)?;

    wtr.serialize(&data.properties)?;
    wtr.serialize(&data.faces)?;

    for (d, (vec, neigh)) in data
        .nodes
        .iter()
        .zip(data.vertices.iter().zip(&data.neighbors))
    {
        wtr.serialize((
            d,
            vec.to_array(),
            neigh
                .neighbors
                .iter()
                .map(|v| v.to_string())
                .collect::<Vec<_>>()
                .join(","),
            neigh
                .distances
                .iter()
                .map(|v| v.to_string())
                .collect::<Vec<_>>()
                .join(","),
        ))?;
    }
    wtr.flush()?;
    Ok(())
}

pub fn from_csv<P: AsRef<Path>>(path: &P) -> Result<PlanetData, Box<dyn Error>> {
    let mut rdr = reader(path)?;
    let props: PlanetProperties = rdr.deserialize().next().unwrap()?;

    let mut rdr = reader(path)?;
    let faces: Vec<(usize, usize, usize)> = rdr.deserialize().nth(1).unwrap()?;

    let mut rdr = reader(path)?;

    let mut nodes = vec![];
    let mut vertices = vec![];
    let mut neighbors = vec![];

    for result in rdr.deserialize().skip(2) {
        let (data, vec, neigh, dist): (NodeData, [f32; 3], String, String) = result?;
        let n: Vec<usize> = neigh.split(',').map(|s| s.parse().unwrap()).collect();
        let d: Vec<u32> = dist.split(',').map(|s| s.parse().unwrap()).collect();

        assert_eq!(
            n.len(),
            d.len(),
            "Neighbour IDs and distances must have the same length!"
        );

        nodes.push(data);
        vertices.push(Vector3::from(vec));
        neighbors.push(NodeNeighbors {
            neighbors: n,
            distances: d,
        })
    }
    Ok(PlanetData::new(props, nodes, vertices, neighbors, faces))
}

fn reader<P: AsRef<Path>>(path: &P) -> csv::Result<Reader<File>> {
    csv::ReaderBuilder::new()
        .has_headers(false)
        .delimiter(b';')
        .flexible(true)
        .from_path(path)
}
