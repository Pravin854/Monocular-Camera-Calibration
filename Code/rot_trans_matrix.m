function bonus1 = rot_trans_matrix(K, hom)
    rot1 = pinv(K) * hom(:, 1);
    rot2 = pinv(K) * hom(:, 2);
    rot3 = cross(rot1, rot2);
    rot3 = rot3 / norm(rot3);
    trans = pinv(K) * hom(:, 3);
    bonus1 = [rot1 rot2 rot3 trans];

end
