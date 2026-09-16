Preset.seed!

CSAPA_SAMPLES = [
  { name: "CSAPA Paris Bastille", kind: "CSAPA", address: "12 rue de la Roquette", zip: "75011", city: "Paris", dept: "75", phone: "01 43 55 12 34", hours: "Lun-Ven 9h-18h" },
  { name: "CSAPA Lyon Croix-Rousse", kind: "CSAPA", address: "8 montée Saint-Sébastien", zip: "69001", city: "Lyon", dept: "69", phone: "04 72 07 45 67", hours: "Lun-Ven 9h-17h30" },
  { name: "CSAPA Marseille Saint-Charles", kind: "CSAPA", address: "3 boulevard des Dames", zip: "13002", city: "Marseille", dept: "13", phone: "04 91 90 22 33", hours: "Lun-Ven 9h-17h" },
  { name: "CSAPA Bordeaux Chartrons", kind: "CSAPA", address: "21 rue Notre-Dame", zip: "33300", city: "Bordeaux", dept: "33", phone: "05 56 91 88 44", hours: "Lun-Ven 9h-18h" },
  { name: "CSAPA Lille Centre", kind: "CSAPA", address: "45 rue Nationale", zip: "59000", city: "Lille", dept: "59", phone: "03 20 12 34 56", hours: "Lun-Ven 9h-17h" },
  { name: "CSAPA Nantes Erdre", kind: "CSAPA", address: "9 cours des 50 Otages", zip: "44000", city: "Nantes", dept: "44", phone: "02 40 55 66 77", hours: "Lun-Ven 9h-17h30" },
  { name: "CSAPA Toulouse Garonne", kind: "CSAPA", address: "14 allées Jean-Jaurès", zip: "31000", city: "Toulouse", dept: "31", phone: "05 61 23 45 67", hours: "Lun-Ven 9h-18h" },
  { name: "CSAPA Rennes Vilaine", kind: "CSAPA", address: "6 rue de Nantes", zip: "35000", city: "Rennes", dept: "35", phone: "02 99 30 40 50", hours: "Lun-Ven 9h-17h" }
].freeze

CSAPA_SAMPLES.each do |attributes|
  CsapaFacility.find_or_create_by!(name: attributes[:name]) do |facility|
    facility.assign_attributes(attributes)
  end
end
